import SwiftUI

struct ContentView: View {
    var body: some View {
        WorkoutDetailView(workout: .sampleFigmaWorkout)
    }
}

// MARK: - Workout Detail

struct WorkoutDetailView: View {
    let workout: Workout

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                Text(workout.name)
                    .font(.system(size: 48, weight: .black))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 24)

                HStack(spacing: 12) {
                    PillButton(title: "Add interval") {
                        Image("IntervalIcon")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 14, height: 16)
                            .foregroundStyle(Color(hex: 0xF3F3F3))
                    }
                    PillButton(title: "Save template") {
                        Image(systemName: "bookmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color(hex: 0xF3F3F3))
                    }
                }
                .padding(.top, 24)
                .padding(.horizontal, 27)

                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    VStack(spacing: 0) {
                        ForEach(Array(workout.blocks.enumerated()), id: \.element.id) { index, block in
                            if index > 0 {
                                RowDivider()
                            }
                            BlockView(block: block)
                        }
                    }
                    .padding(.horizontal, 32)
                    Spacer(minLength: 0)
                }

                StartButton()
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)

                BottomNav()
                    .padding(.bottom, 24)
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Block

private struct BlockView: View {
    let block: WorkoutBlock

    private var isExpanded: Bool {
        block.phases.count > 1 || block.repeatCount > 1
    }

    var body: some View {
        VStack(spacing: 0) {
            BlockHeaderRow(block: block)

            if isExpanded {
                ForEach(Array(block.phases.enumerated()), id: \.element.id) { index, phase in
                    if index > 0 {
                        RowDivider()
                    }
                    PhaseRow(label: phase.type.displayName, time: phase.duration.mmss)
                }
                if block.repeatCount > 1 {
                    RowDivider()
                    PhaseRow(label: "Repeat", time: "\(block.repeatCount)x")
                }
            }
        }
    }
}

private struct RowDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color(hex: 0x454547))
            .frame(height: 1)
            .padding(.leading, 40)
    }
}

private struct BlockHeaderRow: View {
    let block: WorkoutBlock

    var body: some View {
        HStack(spacing: 12) {
            BlockIcon(block: block)

            Text(block.name)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)

            Spacer()

            Text(block.totalDuration.mmss)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color(hex: 0xCCC7C7))

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color(hex: 0xCCC7C7))
        }
        .padding(.vertical, 12)
    }
}

private struct BlockIcon: View {
    let block: WorkoutBlock

    private var firstType: PhaseType {
        block.phases.first?.type ?? .work
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: 0x282828))
            Image(iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: glyphSize.width, height: glyphSize.height)
                .rotationEffect(.degrees(firstType == .warmup ? 180 : 0))
        }
        .frame(width: 28, height: 28)
    }

    private var iconName: String {
        switch firstType {
        case .warmup, .cooldown: return "CooldownIcon"
        case .work, .rest: return "IntervalIcon"
        }
    }

    private var glyphSize: CGSize {
        switch firstType {
        case .warmup, .cooldown: return CGSize(width: 12, height: 13)
        case .work, .rest: return CGSize(width: 14, height: 16)
        }
    }
}

private struct PhaseRow: View {
    let label: String
    let time: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)

            Spacer()

            Text(time)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(Color(hex: 0xCCC7C7))

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color(hex: 0xCCC7C7))
                .padding(.leading, 4)
        }
        .padding(.leading, 40)
        .padding(.vertical, 14)
    }
}

// MARK: - Buttons & Nav

private struct PillButton<Icon: View>: View {
    let title: String
    @ViewBuilder var icon: () -> Icon

    var body: some View {
        HStack(spacing: 8) {
            icon()
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color(hex: 0xF3F3F3))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 47)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(hex: 0x131313))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(hex: 0x313131), lineWidth: 1)
                )
        )
    }
}

private struct StartButton: View {
    var body: some View {
        Text("Start")
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                RoundedRectangle(cornerRadius: 40)
                    .fill(Color(hex: 0xFE6058))
            )
    }
}

private struct BottomNav: View {
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 0) {
                NavIcon(asset: "HomeIcon", size: 24)
                    .frame(maxWidth: .infinity)
                NavIcon(asset: "TemplatesIcon", size: 24)
                    .frame(maxWidth: .infinity)
            }
            .frame(width: 141, height: 54)
            .background(
                Capsule()
                    .fill(Color(hex: 0x131313))
                    .overlay(Capsule().stroke(Color(hex: 0x363636), lineWidth: 1))
            )

            NavIcon(asset: "WorkoutIcon", size: 24)
                .frame(width: 54, height: 54)
                .background(Circle().fill(Color(hex: 0x363636)))
        }
    }
}

private struct NavIcon: View {
    let asset: String
    let size: CGFloat

    var body: some View {
        Image(asset)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
    }
}

// MARK: - Helpers

private extension TimeInterval {
    var mmss: String {
        let total = Int(self)
        let m = total / 60
        let s = total % 60
        return String(format: "%d:%02d", m, s)
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
    ContentView()
}
