import SwiftUI

/// Test view to demonstrate the TimerWorker functionality
struct TimerTestView: View {
    @State private var worker: TimerWorker
    @State private var log: [String] = []
    
    init(workout: Workout = .sampleFigmaWorkout) {
        _worker = State(initialValue: TimerWorker(workout: workout))
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("Timer Worker Test")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.top, 40)
                
                // Current State
                VStack(spacing: 12) {
                    statusRow(label: "State", value: stateText)
                    statusRow(label: "Block", value: blockText)
                    statusRow(label: "Phase", value: phaseText)
                    statusRow(label: "Repeat", value: "\(worker.currentRepeat)")
                    statusRow(label: "Time", value: worker.formattedTimeRemaining)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: 0x1C1C1C))
                )
                .padding(.horizontal, 24)
                
                // Progress Bars
                VStack(spacing: 16) {
                    progressBar(label: "Phase Progress", progress: worker.progress)
                    progressBar(label: "Total Progress", progress: worker.totalProgress)
                }
                .padding(.horizontal, 24)
                
                // Controls
                HStack(spacing: 12) {
                    if worker.state == .idle || worker.state == .completed {
                        controlButton(title: "Start", color: 0x4CAF50) {
                            setupCallbacks()
                            worker.start()
                        }
                    }
                    
                    if worker.state == .running {
                        controlButton(title: "Pause", color: 0xFF9800) {
                            worker.pause()
                        }
                    }
                    
                    if worker.state == .paused {
                        controlButton(title: "Resume", color: 0x4CAF50) {
                            worker.resume()
                        }
                    }
                    
                    if worker.state != .idle {
                        controlButton(title: "Stop", color: 0xF44336) {
                            worker.stop()
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                // Event Log
                VStack(alignment: .leading, spacing: 8) {
                    Text("Event Log")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    ScrollView {
                        ScrollViewReader { proxy in
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(Array(log.enumerated()), id: \.offset) { index, entry in
                                    Text(entry)
                                        .font(.system(size: 12, design: .monospaced))
                                        .foregroundStyle(Color.green)
                                        .id(index)
                                }
                            }
                            .onChange(of: log.count) { _, _ in
                                if let last = log.indices.last {
                                    proxy.scrollTo(last, anchor: .bottom)
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black)
                    )
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            setupCallbacks()
        }
    }
    
    // MARK: - Helpers
    
    private var stateText: String {
        switch worker.state {
        case .idle: return "Idle"
        case .running: return "Running"
        case .paused: return "Paused"
        case .completed: return "Completed"
        }
    }
    
    private var blockText: String {
        guard let block = worker.currentBlock else { return "—" }
        return "\(worker.currentBlockIndex + 1). \(block.name)"
    }
    
    private var phaseText: String {
        guard let phase = worker.currentPhase else { return "—" }
        return phase.type.displayName
    }
    
    private func setupCallbacks() {
        worker.onPhaseChange = { [self] phase, block in
            addLog("▶ Phase: \(phase.type.displayName) (\(Int(phase.duration))s)")
        }
        
        worker.onBlockChange = { [self] block in
            addLog("▶ Block: \(block.name)")
        }
        
        worker.onWorkoutComplete = { [self] in
            addLog("✓ Workout Complete!")
        }
    }
    
    private func addLog(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        log.append("[\(timestamp)] \(message)")
    }
    
    private func statusRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.6))
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
        }
    }
    
    private func progressBar(label: String, progress: Double) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.6))
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: 0x2C2C2C))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: 0xFE6058))
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 8)
        }
    }
    
    private func controlButton(title: String, color: UInt32, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: color))
                )
        }
    }
}

private extension Color {
    init(hex: UInt32, opacity: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }
}

#Preview {
    TimerTestView()
}
