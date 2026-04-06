import SwiftUI

struct KeyboardView: View {
    @State private var showExtended = false
    @State private var shiftActive = false
    @State private var ctrlActive = false
    @State private var optionActive = false
    @State private var cmdActive = false

    private let keyHeight: CGFloat = 48
    private let keySpacing: CGFloat = 4
    private let standardKeyWidth: CGFloat = 44

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.white.opacity(0.2))
                .frame(width: 40, height: 4)
                .padding(.top, 8)
                .padding(.bottom, 4)

            // Keyboard rows
            VStack(spacing: keySpacing) {
                let rows = showExtended ? KeyLayout.extendedRows : KeyLayout.basicRows
                ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                    HStack(spacing: keySpacing) {
                        ForEach(row) { key in
                            keyButton(for: key)
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(nsColor: NSColor(white: 0.1, alpha: 0.95)))
        )
    }

    @ViewBuilder
    private func keyButton(for key: KeyDef) -> some View {
        let isActive = modifierIsActive(key)
        let displayLabel = resolveLabel(for: key)
        let width = key.width * standardKeyWidth + (key.width - 1) * keySpacing

        Button(action: { handleKeyPress(key) }) {
            Text(displayLabel)
                .font(.system(size: key.width > 2 ? 16 : 18, weight: .medium, design: .rounded))
                .foregroundColor(isActive ? .black : .white)
                .frame(width: width, height: keyHeight)
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

        // Toggle between basic/extended
        if key.keyName == "toggle_extended" {
            showExtended = true
            return
        }
        if key.keyName == "toggle_basic" {
            showExtended = false
            return
        }

        // Modifier toggle
        if key.isModifier, let flag = key.modifierFlag {
            let nowActive = sim.toggleModifier(flag)
            updateModifierState(flag: flag, active: nowActive)
            return
        }

        // Regular key press
        sim.postKey(named: key.keyName)

        // Reset modifier UI state after key press
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
