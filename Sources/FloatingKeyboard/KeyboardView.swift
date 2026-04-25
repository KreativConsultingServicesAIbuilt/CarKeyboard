import SwiftUI

struct KeyboardView: View {
    @State private var showExtended = false
    @State private var shiftActive = false
    @State private var ctrlActive = false
    @State private var optionActive = false
    @State private var cmdActive = false
    @State private var cursorVisible = true
    @State private var pressedKeyId: String? = nil
    @State private var typedText: String = ""

    private let keySpacing: CGFloat = 4
    private let previewHeight: CGFloat = 72

    var body: some View {
        VStack(spacing: 0) {
            // ── Text preview strip ─────────────────────────────────────────
            textPreviewView

            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)

            // ── Keyboard rows ──────────────────────────────────────────────
            GeometryReader { geo in
                let rows = showExtended ? KeyLayout.extendedRows : KeyLayout.basicRows
                let rowCount = CGFloat(rows.count)
                let vPad: CGFloat = 10
                let availableHeight = geo.size.height - vPad * 2 - (rowCount - 1) * keySpacing
                let keyHeight = max(36, availableHeight / rowCount)

                VStack(spacing: keySpacing) {
                    ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                        HStack(spacing: keySpacing) {
                            let totalWeight = row.reduce(CGFloat(0)) { $0 + $1.width }
                            let totalSpacing = CGFloat(row.count - 1) * keySpacing
                            let availableWidth = geo.size.width - 16
                            let unitWidth = (availableWidth - totalSpacing) / totalWeight

                            ForEach(row) { key in
                                keyButton(for: key,
                                          width: key.width * unitWidth,
                                          height: keyHeight)
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, vPad)
            }
        }
        .background(
            Rectangle()
                .fill(Color(nsColor: NSColor(white: 0.08, alpha: 0.97)))
        )
    }

    // ── Text preview ────────────────────────────────────────────────────────
    private var textPreviewView: some View {
        HStack(spacing: 0) {
            // Cursor blink indicator
            Rectangle()
                .fill(Color.blue.opacity(0.7))
                .frame(width: 4)
                .frame(height: previewHeight)

            Text(typedText.isEmpty ? "" : String(typedText.suffix(80)))
                .font(.system(size: 30, weight: .light, design: .default))
                .foregroundColor(.white.opacity(0.92))
                .lineLimit(1)
                .truncationMode(.head)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 18)

            // Clear text button
            if !typedText.isEmpty {
                Button(action: { typedText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white.opacity(0.4))
                }
                .buttonStyle(.plain)
                .padding(.trailing, 8)
            }

            // ── Hide keyboard button ──────────────────────────────
            Button(action: {
                NotificationCenter.default.post(name: .hideKeyboard, object: nil)
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Göm")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.white.opacity(0.75))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.12))
                )
            }
            .buttonStyle(.plain)
            .padding(.trailing, 12)
        }
        .frame(height: previewHeight)
        .frame(maxWidth: .infinity)
        .background(Color(nsColor: NSColor(white: 0.03, alpha: 1.0)))
    }

    // ── Key button ───────────────────────────────────────────────────────────
    @ViewBuilder
    private func keyButton(for key: KeyDef, width: CGFloat, height: CGFloat) -> some View {
        let isActive   = modifierIsActive(key)
        let isPressed  = pressedKeyId == key.id
        let label      = resolveLabel(for: key)

        Button(action: {
            flashKey(key)
            handleKeyPress(key)
        }) {
            Text(label)
                .font(.system(size: min(height * 0.38, 20), weight: .medium, design: .rounded))
                .foregroundColor(isPressed ? .black : (isActive ? .black : .white))
                .frame(width: width, height: height)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isPressed
                              ? Color.white.opacity(0.95)
                              : keyBackground(for: key, isActive: isActive))
                )
                .scaleEffect(isPressed ? 0.88 : 1.0)
                .animation(.spring(response: 0.10, dampingFraction: 0.55), value: isPressed)
        }
        .buttonStyle(.plain)
    }

    private func flashKey(_ key: KeyDef) {
        pressedKeyId = key.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
            if pressedKeyId == key.id { pressedKeyId = nil }
        }
    }

    // ── Styling helpers ──────────────────────────────────────────────────────
    private func keyBackground(for key: KeyDef, isActive: Bool) -> Color {
        if isActive { return Color.white.opacity(0.9) }
        if key.isModifier { return Color.white.opacity(0.15) }
        if key.keyName == "toggle_extended" || key.keyName == "toggle_basic" {
            return Color.blue.opacity(0.4)
        }
        if key.keyName == "toggle_cursor" {
            return cursorVisible ? Color.green.opacity(0.5) : Color.white.opacity(0.1)
        }
        return Color.white.opacity(0.1)
    }

    private func resolveLabel(for key: KeyDef) -> String {
        if shiftActive, let shifted = key.shiftLabel { return shifted }
        return key.label
    }

    private func modifierIsActive(_ key: KeyDef) -> Bool {
        guard let flag = key.modifierFlag else { return false }
        if flag == .maskShift     { return shiftActive }
        if flag == .maskControl   { return ctrlActive }
        if flag == .maskAlternate { return optionActive }
        if flag == .maskCommand   { return cmdActive }
        return false
    }

    // ── Key handling ─────────────────────────────────────────────────────────
    private func handleKeyPress(_ key: KeyDef) {
        let sim = KeySimulator.shared

        if key.keyName == "toggle_extended" { showExtended = true;  return }
        if key.keyName == "toggle_basic"    { showExtended = false; return }
        if key.keyName == "toggle_cursor"   {
            cursorVisible = CursorManager.shared.toggle()
            return
        }

        if key.isModifier, let flag = key.modifierFlag {
            let nowActive = sim.toggleModifier(flag)
            updateModifierState(flag: flag, active: nowActive)
            return
        }

        // Capture shift state BEFORE postKey clears it
        let wasShift = shiftActive
        updateTypedText(for: key, shift: wasShift)

        sim.postKey(named: key.keyName)
        shiftActive  = sim.isShiftActive
        ctrlActive   = sim.isControlActive
        optionActive = sim.isOptionActive
        cmdActive    = sim.isCommandActive
    }

    private func updateModifierState(flag: CGEventFlags, active: Bool) {
        if flag == .maskShift     { shiftActive  = active }
        if flag == .maskControl   { ctrlActive   = active }
        if flag == .maskAlternate { optionActive = active }
        if flag == .maskCommand   { cmdActive    = active }
    }

    // ── Text buffer tracking ─────────────────────────────────────────────────
    private func updateTypedText(for key: KeyDef, shift: Bool) {
        switch key.keyName {
        case "delete":
            if !typedText.isEmpty { typedText.removeLast() }
        case "space":
            typedText.append(" ")
        case "return":
            typedText.append(" ⏎ ")
        case "escape":
            typedText = ""
        case "tab", "left", "right", "up", "down",
             "f1","f2","f3","f4","f5","f6","f7","f8",
             "f9","f10","f11","f12":
            break  // navigation / function keys — no text change
        default:
            // Swedish unicode keys
            if let uni = KeySimulator.unicodeKeys[key.keyName] {
                typedText.append(contentsOf: shift ? uni.shifted : uni.normal)
                return
            }
            // Regular virtual-key keys
            if KeySimulator.virtualKeyCodes[key.keyName] != nil {
                let ch: String
                if shift {
                    ch = key.shiftLabel ?? key.label
                } else if key.shiftLabel == nil {
                    // Pure letter (Q→q, A→a …)
                    ch = key.label.lowercased()
                } else {
                    // Number/symbol key without shift
                    ch = key.label
                }
                if ch.count == 1 { typedText.append(contentsOf: ch) }
            }
        }
    }
}
