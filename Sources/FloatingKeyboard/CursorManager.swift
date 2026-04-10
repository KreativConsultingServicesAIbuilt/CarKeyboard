import Cocoa

final class CursorManager {
    static let shared = CursorManager()

    private(set) var isCursorVisible = false  // default: hidden
    private var monitor: Any?
    private let invisibleCursor: NSCursor

    init() {
        // Create a transparent 1x1 cursor
        let size = NSSize(width: 1, height: 1)
        let image = NSImage(size: size)
        image.lockFocus()
        NSColor.clear.set()
        NSRect(origin: .zero, size: size).fill()
        image.unlockFocus()
        invisibleCursor = NSCursor(image: image, hotSpot: .zero)

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
        // Push the invisible cursor and intercept all mouse moves to keep it set
        invisibleCursor.set()
        monitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved, .leftMouseDragged, .rightMouseDragged]) { [weak self] _ in
            self?.invisibleCursor.set()
        }
        isCursorVisible = false
    }

    private func showCursor() {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
        NSCursor.arrow.set()
        isCursorVisible = true
    }
}
