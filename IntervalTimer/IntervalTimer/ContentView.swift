import SwiftUI

struct ContentView: View {
    var body: some View {
        WorkoutDetailView(workout: .sampleFigmaWorkout)
    }
}

// MARK: - Workout Detail

struct WorkoutDetailView: View {
    let workout: Workout
    @State private var editTarget: PhaseEditTarget?

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
                            BlockView(
                                block: block,
                                onPhaseTap: index == 0 ? { phase in
                                    editTarget = PhaseEditTarget(block: block, phase: phase)
                                } : nil
                            )
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
        .sheet(item: $editTarget) { target in
            EditPhaseSheet(target: target)
                .presentationDetents([.fraction(0.78)])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(40)
                .presentationBackground(Color(hex: 0x1C1C1C))
                .ignoresSafeArea(.container, edges: .bottom)
        }
    }
}

struct PhaseEditTarget: Identifiable {
    let block: WorkoutBlock
    let phase: Phase
    var id: UUID { phase.id }

    var title: String {
        if block.phases.count == 1 {
            return block.name
        }
        return "\(block.name) \(phase.type.displayName.lowercased())"
    }
}

// MARK: - Block

private struct BlockView: View {
    let block: WorkoutBlock
    var onPhaseTap: ((Phase) -> Void)?

    private var isExpanded: Bool {
        block.phases.count > 1 || block.repeatCount > 1
    }

    var body: some View {
        VStack(spacing: 0) {
            BlockHeaderRow(
                block: block,
                onTap: !isExpanded ? phaseTapHandler(for: block.phases.first) : nil
            )

            if isExpanded {
                ForEach(Array(block.phases.enumerated()), id: \.element.id) { index, phase in
                    if index > 0 {
                        RowDivider()
                    }
                    PhaseRow(
                        label: phase.type.displayName,
                        time: phase.duration.mmss,
                        onTap: phaseTapHandler(for: phase)
                    )
                }
                if block.repeatCount > 1 {
                    RowDivider()
                    PhaseRow(label: "Repeat", time: "\(block.repeatCount)x", onTap: nil)
                }
            }
        }
    }

    private func phaseTapHandler(for phase: Phase?) -> (() -> Void)? {
        guard let phase, let onPhaseTap else { return nil }
        return { onPhaseTap(phase) }
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
    var onTap: (() -> Void)?

    var body: some View {
        let row = HStack(spacing: 12) {
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
        .contentShape(Rectangle())

        if let onTap {
            Button(action: onTap) { row }
                .buttonStyle(.plain)
        } else {
            row
        }
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
    var onTap: (() -> Void)?

    var body: some View {
        let row = HStack {
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
        .contentShape(Rectangle())

        if let onTap {
            Button(action: onTap) { row }
                .buttonStyle(.plain)
        } else {
            row
        }
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

// MARK: - Edit Phase Sheet

private struct EditPhaseSheet: View {
    let target: PhaseEditTarget
    private let step: Int
    @Environment(\.dismiss) private var dismiss
    @State private var seconds: Int

    init(target: PhaseEditTarget) {
        self.target = target
        let step: Int
        switch target.phase.type {
        case .warmup, .cooldown: step = 60
        case .work, .rest: step = 5
        }
        self.step = step
        let raw = max(step, Int(target.phase.duration.rounded()))
        _seconds = State(initialValue: (raw / step) * step)
    }

    var body: some View {
        VStack(spacing: 0) {
            sheetHeader

            DurationPicker(seconds: $seconds, step: step)
                .frame(maxHeight: .infinity)
                .padding(.bottom, 20)

            Button {
                target.phase.duration = TimeInterval(seconds)
                dismiss()
            } label: {
                Text("Set")
                    .font(.custom("GTAmericaTrial-Md", size: 20))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        RoundedRectangle(cornerRadius: 40)
                            .fill(Color(hex: 0xFE6058))
                    )
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
    }

    private var sheetHeader: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                Capsule()
                    .fill(Color(hex: 0x4F4F4F))
                    .frame(width: 62, height: 5)
                    .padding(.top, 20)

                Text(target.title)
                    .font(.custom("GTAmericaTrial-Bd", size: 24))
                    .foregroundStyle(.white)
                    .padding(.top, 30)

                Text(seconds.mmss)
                    .font(.custom("GTAmericaTrial-CnBlIt", size: 80))
                    .foregroundStyle(.white)
                    .padding(.top, -16)
            }
            .frame(maxWidth: .infinity)

            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(Color(hex: 0x131313))
                                .overlay(Circle().stroke(Color(hex: 0x313131), lineWidth: 1))
                        )
                }
            }
            .padding(.trailing, 24)
            .padding(.top, 24)
        }
    }
}

// MARK: - Duration Picker

private struct DurationPicker: View {
    @Binding var seconds: Int
    private let step: Int
    private let maxSeconds: Int = 1800

    @State private var scrollID: Int?

    init(seconds: Binding<Int>, step: Int) {
        self._seconds = seconds
        self.step = step
    }

    private var values: [Int] {
        // Higher values rendered at the top of the list — scrolling visually
        // moves the selection up to higher times.
        Array(stride(from: step, through: maxSeconds, by: step)).reversed()
    }

    // 60pt per minute baseline → scale for smaller steps
    private var rowHeight: CGFloat {
        CGFloat(step)
    }

    var body: some View {
        GeometryReader { proxy in
            let halfHeight = proxy.size.height / 2

            ZStack {
                ScrollViewReader { reader in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(values, id: \.self) { sec in
                                TickRow(
                                    label: sec.mmss,
                                    height: rowHeight,
                                    isMajor: (sec / step) % 5 == 0
                                )
                                .id(sec)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .contentMargins(.vertical, halfHeight, for: .scrollContent)
                    .scrollPosition(id: $scrollID, anchor: .center)
                    .scrollTargetBehavior(.viewAligned(limitBehavior: .alwaysByOne))
                    .onAppear {
                        Task { @MainActor in
                            try? await Task.sleep(nanoseconds: 100_000_000)
                            reader.scrollTo(seconds, anchor: .center)
                        }
                    }
                    .onChange(of: scrollID) { _, newValue in
                        if let newValue, newValue != seconds {
                            seconds = newValue
                        }
                    }
                }

                SelectedIndicator()
                    .allowsHitTesting(false)

                fadeOverlay
                    .allowsHitTesting(false)
            }
        }
    }

    private var fadeOverlay: some View {
        let sheetBg = Color(hex: 0x1C1C1C)
        return VStack(spacing: 0) {
            LinearGradient(
                stops: [
                    .init(color: sheetBg, location: 0.0),
                    .init(color: sheetBg, location: 0.45),
                    .init(color: sheetBg.opacity(0), location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 110)
            Spacer()
            LinearGradient(
                stops: [
                    .init(color: sheetBg.opacity(0), location: 0.0),
                    .init(color: sheetBg, location: 0.55),
                    .init(color: sheetBg, location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 110)
        }
    }
}

private struct TickRow: View {
    let label: String
    let height: CGFloat
    let isMajor: Bool

    // Decorative tick offsets within the row (relative to row center).
    // Spacing is 10pt; the offset at +30 (or -30) sits on the row boundary
    // so it visually merges with the neighbouring row's boundary tick — this
    // produces an even 10pt rhythm across the whole picker with no gaps.
    private let decorativeOffsets: [CGFloat] = [-30, -20, -10, 10, 20, 30]

    var body: some View {
        ZStack {
            Color.clear.frame(height: height)

            // Label: right-aligned, right edge at 84pt from sheet leading edge
            HStack(spacing: 0) {
                Text(label)
                    .font(.custom("GTAmericaTrial-Md", size: 18))
                    .foregroundStyle(Color.white.opacity(0.7))
            }
            .frame(width: 84, alignment: .trailing)
            .frame(maxWidth: .infinity, alignment: .leading)

            // Tick stack centered horizontally
            ZStack {
                ForEach(decorativeOffsets, id: \.self) { dy in
                    Rectangle()
                        .fill(Color.white.opacity(0.25))
                        .frame(width: 24, height: 1)
                        .offset(y: dy)
                }
                // Minute tick at row center — 40pt every 5 minutes, 24pt otherwise
                Rectangle()
                    .fill(Color.white.opacity(isMajor ? 0.55 : 0.35))
                    .frame(width: isMajor ? 40 : 24, height: 1)
            }
        }
    }
}

private struct SelectedIndicator: View {
    var body: some View {
        Image("SelectedPill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 179, height: 21)
    }
}

private extension Int {
    var mmss: String {
        let m = self / 60
        let s = self % 60
        return String(format: "%d:%02d", m, s)
    }
}

#Preview {
    ContentView()
}
