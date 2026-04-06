import SwiftUI

struct KeyboardView: View {
    @State private var showExtended = false
    @State private var shiftActive = false
    @State private var ctrlActive = false
    @State private var optionActive = false
    @State private var cmdActive = false

    private let keySpacing: CGFloat = 4

    var body: some View {
        GeometryReader { geo in
            let rows = showExtended ? KeyLayout.extendedRows : KeyLayout.basicRows
            let rowCount = CGFloat(rows.count)
            let topPadding: CGFloat = 12
            let bottomPadding: CGFloat = 12
            let availableHeight = geo.size.height - topPadding - bottomPadding - (rowCount - 1) * keySpacing
            let keyHeight = max(36, availableHeight / rowCount)

            VStack(spacing: keySpacing) {
                ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                    HStack(spacing: keySpacing) {
                        let totalWeight = row.reduce(CGFloat(0)) { $0 + $1.width }
                        let totalSpacing = CGFloat(row.count - 1) * keySpacing
                        let availableWidth = geo.size.width - 16  // 8px padding each side
                        let unitWidth = (availableWidth - totalSpacing) / totalWeight

                        ForEach(row) { key in
                            keyButton(for: key, width: key.width * unitWidth, height: keyHeight)
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, topPadding)
            .padding(.bottom, bottomPadding)
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(nsColor: NSColor(white: 0.08, alpha: 0.95)))
        )
    }

    @ViewBuilder
    private func keyButton(for key: KeyDef, width: CGFloat, height: CGFloat) -> some View {
        let isActive = modifierIsActive(key)
        let displayLabel = resolveLabel(for: key)

        Button(action: { handleKeyPress(key) }) {
            Text(displayLabel)
                .font(.system(size: min(height * 0.4, 20), weight: .medium, design: .rounded))
                .foregroundColor(isActive ? .black : .white)
                .frame(width: width, height: height)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(keyBackground(for: key, isActive: isActive))
                )
        }
        .buttonStyle(.plain)
    }

    private func keyBackground(for key: KeyDef, isActive: Bool) -> Color {
        if isActive {
            return Color.white.opacity(0.9)
        }
        if key.isModifier {
            return Color.white.opacity(0.15)
        }
        if key.keyName == "toggle_extended" || key.keyName == "toggle_basic" {
            return Color.blue.opacity(0.4)
        }
        return Color.white.opacity(0.1)
    }

    private func resolveLabel(for key: KeyDef) -> String {
        if shiftActive, let shifted = key.shiftLabel {
            return shifted
        }
        return key.label
    }

    private func modifierIsActive(_ key: KeyDef) -> Bool {
        guard let flag = key.modifierFlag else { return false }
        if flag == .maskShift { return shiftActive }
        if flag == .maskControl { return ctrlActive }
        if flag == .maskAlternate { return optionActive }
        if flag == .maskCommand { return cmdActive }
        return false
    }

    private func handleKeyPress(_ key: KeyDef) {
        let sim = KeySimulator.shared

        if key.keyName == "toggle_extended" {
            showExtended = true
            return
        }
        if key.keyName == "toggle_basic" {
            showExtended = false
            return
        }

        if key.isModifier, let flag = key.modifierFlag {
            let nowActive = sim.toggleModifier(flag)
            updateModifierState(flag: flag, active: nowActive)
            return
        }

        sim.postKey(named: key.keyName)

        shiftActive = sim.isShiftActive
        ctrlActive = sim.isControlActive
        optionActive = sim.isOptionActive
        cmdActive = sim.isCommandActive
    }

    private func updateModifierState(flag: CGEventFlags, active: Bool) {
        if flag == .maskShift { shiftActive = active }
        if flag == .maskControl { ctrlActive = active }
        if flag == .maskAlternate { optionActive = active }
        if flag == .maskCommand { cmdActive = active }
    }
}
