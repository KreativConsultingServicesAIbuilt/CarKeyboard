import Cocoa

final class CursorManager {
    static let shared = CursorManager()

    // Default: cursor visible (cursor hiding is opt-in via the button)
    private(set) var isCursorVisible = true

    func toggle() -> Bool {
        if isCursorVisible {
            hideCursor()
        } else {
            showCursor()
        }
        return isCursorVisible
    }

    private func hideCursor() {
        // Move cursor to bottom-right corner and keep it there
        guard let screen = NSScreen.main else { return }
        let corner = CGPoint(x: screen.frame.maxX - 1, y: screen.frame.maxY - 1)
        CGWarpMouseCursorPosition(corner)
        isCursorVisible = false
    }

    private func showCursor() {
        // Move cursor to center of screen
        guard let screen = NSScreen.main else { return }
        let center = CGPoint(x: screen.frame.midX, y: screen.frame.midY)
        CGWarpMouseCursorPosition(center)
        isCursorVisible = true
    }
}
