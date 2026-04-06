import Cocoa
import Carbon.HIToolbox

final class KeySimulator {
    static let shared = KeySimulator()

    private var activeModifiers: CGEventFlags = []

    // Map of virtual key codes (Carbon)
    static let virtualKeyCodes: [String: CGKeyCode] = [
        // Letters
        "a": 0x00, "s": 0x01, "d": 0x02, "f": 0x03, "h": 0x04,
        "g": 0x05, "z": 0x06, "x": 0x07, "c": 0x08, "v": 0x09,
        "b": 0x0B, "q": 0x0C, "w": 0x0D, "e": 0x0E, "r": 0x0F,
        "y": 0x10, "t": 0x11, "1": 0x12, "2": 0x13, "3": 0x14,
        "4": 0x15, "6": 0x16, "5": 0x17, "9": 0x19, "7": 0x1A,
        "8": 0x1C, "0": 0x1D, "o": 0x1F, "u": 0x20, "i": 0x22,
        "p": 0x23, "l": 0x25, "j": 0x26, "k": 0x28, "n": 0x2D,
        "m": 0x2E,
        // Special keys
        "return": 0x24, "tab": 0x30, "space": 0x31, "delete": 0x33,
        "escape": 0x35, "period": 0x2F, "comma": 0x2B,
        "slash": 0x2C, "semicolon": 0x29, "quote": 0x27,
        "minus": 0x1B, "equal": 0x18,
        "leftbracket": 0x21, "rightbracket": 0x1E,
        "backslash": 0x2A, "grave": 0x32,
        // Arrow keys
        "left": 0x7B, "right": 0x7C, "down": 0x7D, "up": 0x7E,
        // Function keys
        "f1": 0x7A, "f2": 0x78, "f3": 0x63, "f4": 0x76,
        "f5": 0x60, "f6": 0x61, "f7": 0x62, "f8": 0x64,
        "f9": 0x65, "f10": 0x6D, "f11": 0x67, "f12": 0x6F,
    ]

    func postKeyEvent(keyCode: CGKeyCode) {
        let source = CGEventSource(stateID: .hidSystemState)

        guard let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true),
              let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false) else {
            return
        }

        keyDown.flags = activeModifiers
        keyUp.flags = activeModifiers

        keyDown.post(tap: .cghidEventTap)
        keyUp.post(tap: .cghidEventTap)

        // Clear non-sticky modifiers after key press
        activeModifiers = []
    }

    // Unicode characters for keys without virtual key codes (e.g. Swedish letters)
    static let unicodeKeys: [String: (normal: String, shifted: String)] = [
        "sv_aa": ("å", "Å"),
        "sv_ae": ("ä", "Ä"),
        "sv_oe": ("ö", "Ö"),
    ]

    func postUnicodeKey(_ char: String) {
        let source = CGEventSource(stateID: .hidSystemState)
        guard let event = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true) else { return }

        let utf16 = Array(char.utf16)
        event.keyboardSetUnicodeString(stringLength: utf16.count, unicodeString: utf16)
        event.post(tap: .cghidEventTap)

        if let upEvent = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: false) {
            upEvent.post(tap: .cghidEventTap)
        }

        activeModifiers = []
    }

    func postKey(named name: String) {
        // Check for Unicode keys first (Swedish letters etc.)
        if let unicode = KeySimulator.unicodeKeys[name.lowercased()] {
            let char = isShiftActive ? unicode.shifted : unicode.normal
            postUnicodeKey(char)
            return
        }
        guard let keyCode = KeySimulator.virtualKeyCodes[name.lowercased()] else { return }
        postKeyEvent(keyCode: keyCode)
    }

    func toggleModifier(_ flag: CGEventFlags) -> Bool {
        if activeModifiers.contains(flag) {
            activeModifiers.remove(flag)
            return false
        } else {
            activeModifiers.insert(flag)
            return true
        }
    }

    func clearModifiers() {
        activeModifiers = []
    }

    var isShiftActive: Bool { activeModifiers.contains(.maskShift) }
    var isCommandActive: Bool { activeModifiers.contains(.maskCommand) }
    var isOptionActive: Bool { activeModifiers.contains(.maskAlternate) }
    var isControlActive: Bool { activeModifiers.contains(.maskControl) }
}
