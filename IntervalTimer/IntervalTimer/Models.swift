import Foundation
import SwiftData

// MARK: - Workout

@Model
final class Workout {
    var id: UUID
    var name: String
    var intervals: [Interval]
    var createdDate: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        intervals: [Interval] = [],
        createdDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.intervals = intervals
        self.createdDate = createdDate
    }
    
    var totalDuration: TimeInterval {
        intervals.reduce(0) { $0 + $1.workDuration + $1.restDuration }
    }
}

// MARK: - Interval

@Model
final class Interval {
    var id: UUID
    var type: IntervalType
    var workDuration: TimeInterval
    var restDuration: TimeInterval
    var notes: String?
    
    init(
        id: UUID = UUID(),
        type: IntervalType,
        workDuration: TimeInterval,
        restDuration: TimeInterval,
        notes: String? = nil
    ) {
        self.id = id
        self.type = type
        self.workDuration = workDuration
        self.restDuration = restDuration
        self.notes = notes
    }
}

// MARK: - Interval Type

enum IntervalType: String, Codable, CaseIterable {
    case warmup
    case work
    case rest
    case cooldown
    
    var displayName: String {
        switch self {
        case .warmup: return "Warm-up"
        case .work: return "Work"
        case .rest: return "Rest"
        case .cooldown: return "Cool-down"
        }
    }
}

// MARK: - Sample Data

extension Workout {
    static var sampleHIIT: Workout {
        Workout(
            name: "Classic HIIT",
            intervals: [
                Interval(type: .warmup, workDuration: 120, restDuration: 0),
                Interval(type: .work, workDuration: 20, restDuration: 10),
                Interval(type: .work, workDuration: 20, restDuration: 10),
                Interval(type: .work, workDuration: 20, restDuration: 10),
                Interval(type: .work, workDuration: 20, restDuration: 10),
                Interval(type: .cooldown, workDuration: 120, restDuration: 0)
            ]
        )
    }
}
