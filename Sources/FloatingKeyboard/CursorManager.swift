import Cocoa

final class CursorManager {
    static let shared = CursorManager()

    private(set) var isCursorVisible = false  // default: hidden

    init() {
        // Hide cursor on launch
        hideCursor()
    }

    func toggle() -> Bool {
        if isCursorVisible {
            hideCursor()
        } else {
            showCursor()
        }
        return isCursorVisible
    }

    private func hideCursor() {
        CGDisplayHideCursor(CGMainDisplayID())
        isCursorVisible = false
    }

    private func showCursor() {
        CGDisplayShowCursor(CGMainDisplayID())
        isCursorVisible = true
    }
}
