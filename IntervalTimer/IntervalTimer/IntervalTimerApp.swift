//
//  IntervalTimerApp.swift
//  IntervalTimer
//
//  Created by Michael Mazur on 5/21/26.
//

import SwiftUI
import SwiftData

@main
struct IntervalTimerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Workout.self, WorkoutBlock.self, Phase.self])
    }
}
