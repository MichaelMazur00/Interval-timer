import Foundation
import Combine

/// Manages the execution of a workout's timer, progressing through phases and blocks
@MainActor
@Observable
final class TimerWorker {
    
    // MARK: - State
    
    enum State {
        case idle
        case running
        case paused
        case completed
    }
    
    private(set) var state: State = .idle
    private(set) var currentBlockIndex: Int = 0
    private(set) var currentPhaseIndex: Int = 0
    private(set) var currentRepeat: Int = 1
    private(set) var timeRemaining: TimeInterval = 0
    
    // MARK: - Properties
    
    private let workout: Workout
    private var timer: Timer?
    private var startTime: Date?
    private var pausedTime: Date?
    
    // MARK: - Computed
    
    var currentBlock: WorkoutBlock? {
        guard currentBlockIndex < workout.blocks.count else { return nil }
        return workout.blocks[currentBlockIndex]
    }
    
    var currentPhase: Phase? {
        guard let block = currentBlock,
              currentPhaseIndex < block.phases.count else { return nil }
        return block.phases[currentPhaseIndex]
    }
    
    var progress: Double {
        guard let currentPhase else { return 0 }
        let elapsed = currentPhase.duration - timeRemaining
        return elapsed / currentPhase.duration
    }
    
    var totalProgress: Double {
        let totalDuration = workout.totalDuration
        guard totalDuration > 0 else { return 0 }
        
        var elapsed: TimeInterval = 0
        
        // Add completed blocks
        for (index, block) in workout.blocks.enumerated() {
            if index < currentBlockIndex {
                elapsed += block.totalDuration
            } else if index == currentBlockIndex {
                // Add completed repeats in current block
                if let currentBlock {
                    elapsed += currentBlock.phasesDuration * Double(currentRepeat - 1)
                    
                    // Add completed phases in current repeat
                    for (phaseIndex, phase) in currentBlock.phases.enumerated() {
                        if phaseIndex < currentPhaseIndex {
                            elapsed += phase.duration
                        } else if phaseIndex == currentPhaseIndex {
                            elapsed += (phase.duration - timeRemaining)
                        }
                    }
                }
                break
            }
        }
        
        return elapsed / totalDuration
    }
    
    // MARK: - Callbacks
    
    var onPhaseChange: ((Phase, WorkoutBlock) -> Void)?
    var onBlockChange: ((WorkoutBlock) -> Void)?
    var onWorkoutComplete: (() -> Void)?
    var onTick: ((TimeInterval) -> Void)?
    
    // MARK: - Init
    
    init(workout: Workout) {
        self.workout = workout
    }
    
    // MARK: - Control
    
    func start() {
        guard state == .idle || state == .paused else { return }
        
        if state == .idle {
            reset()
            moveToFirstPhase()
        }
        
        state = .running
        startTime = Date()
        startTimer()
    }
    
    func pause() {
        guard state == .running else { return }
        
        state = .paused
        pausedTime = Date()
        stopTimer()
    }
    
    func resume() {
        guard state == .paused else { return }
        start()
    }
    
    func stop() {
        state = .idle
        stopTimer()
        reset()
    }
    
    // MARK: - Private
    
    private func reset() {
        currentBlockIndex = 0
        currentPhaseIndex = 0
        currentRepeat = 1
        timeRemaining = 0
        startTime = nil
        pausedTime = nil
    }
    
    private func moveToFirstPhase() {
        guard let firstBlock = workout.blocks.first,
              let firstPhase = firstBlock.phases.first else {
            return
        }
        
        timeRemaining = firstPhase.duration
        onPhaseChange?(firstPhase, firstBlock)
        onBlockChange?(firstBlock)
    }
    
    private func startTimer() {
        stopTimer()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func tick() {
        guard state == .running else { return }
        
        timeRemaining -= 0.1
        onTick?(timeRemaining)
        
        if timeRemaining <= 0 {
            advanceToNextPhase()
        }
    }
    
    private func advanceToNextPhase() {
        guard let currentBlock else {
            complete()
            return
        }
        
        // Try to move to next phase in current block
        let nextPhaseIndex = currentPhaseIndex + 1
        
        if nextPhaseIndex < currentBlock.phases.count {
            // Move to next phase
            currentPhaseIndex = nextPhaseIndex
            if let nextPhase = currentPhase {
                timeRemaining = nextPhase.duration
                onPhaseChange?(nextPhase, currentBlock)
            }
        } else if currentRepeat < currentBlock.repeatCount {
            // Repeat current block
            currentRepeat += 1
            currentPhaseIndex = 0
            if let firstPhase = currentBlock.phases.first {
                timeRemaining = firstPhase.duration
                onPhaseChange?(firstPhase, currentBlock)
            }
        } else {
            // Move to next block
            let nextBlockIndex = currentBlockIndex + 1
            
            if nextBlockIndex < workout.blocks.count {
                currentBlockIndex = nextBlockIndex
                currentPhaseIndex = 0
                currentRepeat = 1
                
                if let nextBlock = currentBlock,
                   let firstPhase = nextBlock.phases.first {
                    timeRemaining = firstPhase.duration
                    onBlockChange?(nextBlock)
                    onPhaseChange?(firstPhase, nextBlock)
                }
            } else {
                // Workout complete
                complete()
            }
        }
    }
    
    private func complete() {
        state = .completed
        stopTimer()
        onWorkoutComplete?()
    }
}

// MARK: - Formatting Helper

extension TimerWorker {
    var formattedTimeRemaining: String {
        timeRemaining.mmss
    }
}

private extension TimeInterval {
    var mmss: String {
        let total = max(0, Int(ceil(self)))
        let m = total / 60
        let s = total % 60
        return String(format: "%d:%02d", m, s)
    }
}
