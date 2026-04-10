import Cocoa

final class CursorManager {
    static let shared = CursorManager()

    private(set) var isCursorVisible = false  // default: hidden

    init() {
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
        // Move cursor to bottom-right corner and disconnect mouse from cursor position
        guard let screen = NSScreen.main else { return }
        let corner = CGPoint(x: screen.frame.maxX - 1, y: screen.frame.maxY - 1)
        CGWarpMouseCursorPosition(corner)
        CGAssociateMouseAndMouseCursorPosition(boolean_t(0))
        isCursorVisible = false
    }

    private func showCursor() {
        // Re-associate mouse with cursor position
        CGAssociateMouseAndMouseCursorPosition(boolean_t(1))
        isCursorVisible = true
    }
}
