# Timer Worker

This document explains the `TimerWorker` implementation for executing interval workouts.

## Overview

The `TimerWorker` is a Swift `@Observable` class that manages the execution of a `Workout`, progressing through blocks, phases, and repeats while providing real-time updates.

## Features

- **State Management**: Tracks idle, running, paused, and completed states
- **Progress Tracking**: Provides both phase-level and workout-level progress
- **Callback System**: Notifies on phase changes, block changes, and completion
- **Auto-advance**: Automatically progresses through phases, repeats, and blocks
- **Time Formatting**: Includes helper methods for displaying time in MM:SS format

## Usage

### Basic Setup

```swift
// Create a worker with a workout
let worker = TimerWorker(workout: myWorkout)

// Set up callbacks
worker.onPhaseChange = { phase, block in
    print("Now in \(phase.type.displayName) phase")
}

worker.onBlockChange = { block in
    print("Starting block: \(block.name)")
}

worker.onWorkoutComplete = {
    print("Workout finished!")
}

worker.onTick = { timeRemaining in
    // Update UI every 0.1 seconds
}

// Start the timer
worker.start()
```

### State Control

```swift
// Pause the timer
worker.pause()

// Resume from pause
worker.resume()

// Stop and reset
worker.stop()
```

### Accessing Current State

```swift
// Current state
let state = worker.state // .idle, .running, .paused, .completed

// Current position
let block = worker.currentBlock
let phase = worker.currentPhase
let repeat = worker.currentRepeat

// Progress
let phaseProgress = worker.progress // 0.0 to 1.0
let totalProgress = worker.totalProgress // 0.0 to 1.0

// Time remaining
let time = worker.timeRemaining
let formatted = worker.formattedTimeRemaining // "5:30"
```

## Testing

A test view is included in `TimerTestView.swift` that demonstrates the worker's functionality:

1. **To test in the app**: Change `ContentView.swift` to show `TimerTestView()` instead
2. **Run the app** and use the controls to start, pause, resume, and stop the timer
3. **Watch the event log** to see phase and block transitions in real-time

### Quick Test

```swift
@main
struct IntervalTimerApp: App {
    var body: some Scene {
        WindowGroup {
            TimerTestView() // Use this instead of ContentView()
        }
        .modelContainer(for: [Workout.self, WorkoutBlock.self, Phase.self])
    }
}
```

## Architecture

### Timer Execution Flow

1. **Start** → Initializes to the first block's first phase
2. **Tick** → Decrements time every 0.1 seconds
3. **Phase Complete** → Advances to next phase
4. **All Phases Complete** → Either repeats the block or advances to next block
5. **All Blocks Complete** → Marks workout as completed

### Thread Safety

The `TimerWorker` is marked with `@MainActor` to ensure all state updates happen on the main thread, making it safe for SwiftUI integration.

## Future Enhancements

Potential additions for production use:

- **Background Support**: Continue running when app is backgrounded
- **Audio Cues**: Play sounds on phase transitions
- **Haptic Feedback**: Vibrate on key events
- **Persistence**: Save/restore timer state
- **Notifications**: Local notifications for phase changes
- **Custom Intervals**: Allow skipping or jumping to specific phases
