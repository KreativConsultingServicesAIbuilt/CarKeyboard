import Foundation
import CoreGraphics

struct KeyDef: Identifiable {
    let id: String
    let label: String
    let shiftLabel: String?
    let keyName: String
    let width: CGFloat  // multiplier of standard key width
    let isModifier: Bool
    let modifierFlag: CGEventFlags?

    init(
        _ label: String,
        keyName: String? = nil,
        shift: String? = nil,
        width: CGFloat = 1.0,
        isModifier: Bool = false,
        modifierFlag: CGEventFlags? = nil
    ) {
        self.id = label + (keyName ?? label)
        self.label = label
        self.shiftLabel = shift
        self.keyName = keyName ?? label.lowercased()
        self.width = width
        self.isModifier = isModifier
        self.modifierFlag = modifierFlag
    }
}

struct KeyLayout {
    // Basic QWERTY layer
    static let basicRows: [[KeyDef]] = [
        // Number row
        [
            KeyDef("1", shift: "!"), KeyDef("2", shift: "@"), KeyDef("3", shift: "#"),
            KeyDef("4", shift: "$"), KeyDef("5", shift: "%"), KeyDef("6", shift: "^"),
            KeyDef("7", shift: "&"), KeyDef("8", shift: "*"), KeyDef("9", shift: "("),
            KeyDef("0", shift: ")"), KeyDef("-", keyName: "minus", shift: "_"),
            KeyDef("⌫", keyName: "delete", width: 1.5),
        ],
        // Top letter row
        [
            KeyDef("Q"), KeyDef("W"), KeyDef("E"), KeyDef("R"), KeyDef("T"),
            KeyDef("Y"), KeyDef("U"), KeyDef("I"), KeyDef("O"), KeyDef("P"),
            KeyDef("Å", keyName: "sv_aa", shift: "Å"),
        ],
        // Home row
        [
            KeyDef("A"), KeyDef("S"), KeyDef("D"), KeyDef("F"), KeyDef("G"),
            KeyDef("H"), KeyDef("J"), KeyDef("K"), KeyDef("L"),
            KeyDef("Ö", keyName: "sv_oe", shift: "Ö"),
            KeyDef("Ä", keyName: "sv_ae", shift: "Ä"),
        ],
        // Bottom row
        [
            KeyDef("⇧", keyName: "shift", width: 1.5, isModifier: true, modifierFlag: .maskShift),
            KeyDef("Z"), KeyDef("X"), KeyDef("C"), KeyDef("V"),
            KeyDef("B"), KeyDef("N"), KeyDef("M"),
            KeyDef(",", keyName: "comma", shift: "<"),
            KeyDef(".", keyName: "period", shift: ">"),
        ],
        // Space row
        [
            KeyDef("⌨", keyName: "toggle_extended", width: 1.5),
            KeyDef("🖱", keyName: "toggle_cursor", width: 1.0),
            KeyDef("Space", keyName: "space", width: 4.0),
            KeyDef("⏎", keyName: "return", width: 1.5),
        ],
    ]

    // Extended layer (modifiers + extras)
    static let extendedRows: [[KeyDef]] = [
        [
            KeyDef("Esc", keyName: "escape"),
            KeyDef("F1", keyName: "f1"), KeyDef("F2", keyName: "f2"),
            KeyDef("F3", keyName: "f3"), KeyDef("F4", keyName: "f4"),
            KeyDef("F5", keyName: "f5"), KeyDef("F6", keyName: "f6"),
            KeyDef("F7", keyName: "f7"), KeyDef("F8", keyName: "f8"),
        ],
        [
            KeyDef("`", keyName: "grave", shift: "~"),
            KeyDef("[", keyName: "leftbracket", shift: "{"),
            KeyDef("]", keyName: "rightbracket", shift: "}"),
            KeyDef("\\", keyName: "backslash", shift: "|"),
            KeyDef("/", keyName: "slash", shift: "?"),
            KeyDef("'", keyName: "quote", shift: "\""),
            KeyDef("=", keyName: "equal", shift: "+"),
        ],
        [
            KeyDef("⇧", keyName: "shift", width: 1.3, isModifier: true, modifierFlag: .maskShift),
            KeyDef("⌃", keyName: "control", width: 1.3, isModifier: true, modifierFlag: .maskControl),
            KeyDef("⌥", keyName: "option", width: 1.3, isModifier: true, modifierFlag: .maskAlternate),
            KeyDef("⌘", keyName: "command", width: 1.3, isModifier: true, modifierFlag: .maskCommand),
            KeyDef("Tab", keyName: "tab", width: 1.3),
        ],
        [
            KeyDef("←", keyName: "left", width: 1.5),
            KeyDef("↓", keyName: "down", width: 1.5),
            KeyDef("↑", keyName: "up", width: 1.5),
            KeyDef("→", keyName: "right", width: 1.5),
        ],
        [
            KeyDef("ABC", keyName: "toggle_basic", width: 1.5),
            KeyDef("Space", keyName: "space", width: 5.0),
            KeyDef("⏎", keyName: "return", width: 1.5),
        ],
    ]
}
