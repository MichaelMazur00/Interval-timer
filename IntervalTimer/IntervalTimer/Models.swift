import Foundation

// MARK: - Workout

struct Workout: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var intervals: [Interval]
    var createdDate: Date = Date()
    
    var totalDuration: TimeInterval {
        intervals.reduce(0) { $0 + $1.workDuration + $1.restDuration }
    }
}

// MARK: - Interval

struct Interval: Identifiable, Codable {
    var id: UUID = UUID()
    var type: IntervalType
    var workDuration: TimeInterval
    var restDuration: TimeInterval
    var notes: String?
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
    static let sampleHIIT = Workout(
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
