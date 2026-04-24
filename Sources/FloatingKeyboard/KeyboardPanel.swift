import Cocoa

/// A floating, non-activating panel that stays above all other windows.
/// Clicking keys on this panel does NOT steal focus from the target app.
final class KeyboardPanel: NSPanel {
    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )

        // Float above ALL windows — above menu bar, status bar, pop-up menus
        // NSWindow.Level.popUpMenu = 101; well above .floating (3) and .mainMenu (24)
        level = .popUpMenu
        isFloatingPanel = true

        // Don't steal focus
        becomesKeyOnlyIfNeeded = true

        // Transparent / rounded appearance
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true

        // Keep visible across spaces
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        // No title bar
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
    }

    // Allow mouse events even though panel is non-activating
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}
