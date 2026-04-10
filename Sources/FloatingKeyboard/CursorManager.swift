import Cocoa

final class CursorManager {
    static let shared = CursorManager()

    private(set) var isCursorVisible = false  // default: hidden
    private var hideTimer: Timer?

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
        // Use NSCursor.hide() repeatedly to keep it hidden,
        // and set up a timer to keep re-hiding since the system
        // will show it again on mouse movement
        NSCursor.hide()
        hideTimer?.invalidate()
        hideTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            NSCursor.hide()
        }
        isCursorVisible = false
    }

    private func showCursor() {
        hideTimer?.invalidate()
        hideTimer = nil
        // Unhide enough times to counter all the hides
        for _ in 0..<100 {
            NSCursor.unhide()
        }
        isCursorVisible = true
    }
}
