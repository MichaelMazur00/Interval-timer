import Foundation
import SwiftData

// MARK: - Workout

@Model
final class Workout {
    var id: UUID
    var name: String
    var createdDate: Date

    @Relationship(deleteRule: .cascade, inverse: \WorkoutBlock.workout)
    var blocks: [WorkoutBlock] = []

    init(
        id: UUID = UUID(),
        name: String,
        blocks: [WorkoutBlock] = [],
        createdDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.createdDate = createdDate
        self.blocks = blocks
    }

    var totalDuration: TimeInterval {
        blocks.reduce(0) { $0 + $1.totalDuration }
    }
}

// MARK: - WorkoutBlock

@Model
final class WorkoutBlock {
    var id: UUID
    var name: String
    var repeatCount: Int
    var workout: Workout?

    @Relationship(deleteRule: .cascade, inverse: \Phase.block)
    var phases: [Phase] = []

    init(
        id: UUID = UUID(),
        name: String,
        repeatCount: Int = 1,
        phases: [Phase] = []
    ) {
        self.id = id
        self.name = name
        self.repeatCount = repeatCount
        self.phases = phases
    }

    var phasesDuration: TimeInterval {
        phases.reduce(0) { $0 + $1.duration }
    }

    var totalDuration: TimeInterval {
        phasesDuration * Double(repeatCount)
    }
}

// MARK: - Phase

@Model
final class Phase {
    var id: UUID
    var type: PhaseType
    var duration: TimeInterval
    var block: WorkoutBlock?

    init(
        id: UUID = UUID(),
        type: PhaseType,
        duration: TimeInterval
    ) {
        self.id = id
        self.type = type
        self.duration = duration
    }
}

// MARK: - Phase Type

enum PhaseType: String, Codable, CaseIterable {
    case warmup
    case work
    case rest
    case cooldown

    var displayName: String {
        switch self {
        case .warmup: return "Warm up"
        case .work: return "Work"
        case .rest: return "Rest"
        case .cooldown: return "Cool down"
        }
    }
}

// MARK: - Sample Data

extension Workout {
    static var sampleFigmaWorkout: Workout {
        Workout(
            name: "Workout",
            blocks: [
                WorkoutBlock(
                    name: "Warm up",
                    phases: [Phase(type: .warmup, duration: 600)]
                ),
                WorkoutBlock(
                    name: "Interval",
                    repeatCount: 10,
                    phases: [
                        Phase(type: .work, duration: 75),
                        Phase(type: .rest, duration: 180)
                    ]
                ),
                WorkoutBlock(
                    name: "Cool down",
                    phases: [Phase(type: .cooldown, duration: 600)]
                )
            ]
        )
    }
}
