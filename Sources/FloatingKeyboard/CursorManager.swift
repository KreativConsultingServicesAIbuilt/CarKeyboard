import Cocoa

final class CursorManager {
    static let shared = CursorManager()

    private(set) var isCursorVisible = false  // default: hidden
    private var blankWindow: NSWindow?

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
        // Create a fullscreen transparent window at the highest level
        // with a blank cursor set — this covers the entire screen
        // and forces the cursor to be invisible everywhere
        guard let screen = NSScreen.main else { return }

        let window = NSWindow(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.level = .screenSaver
        window.isOpaque = false
        window.backgroundColor = .clear
        window.ignoresMouseEvents = true  // clicks pass through
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.hasShadow = false

        // Create transparent cursor
        let cursorImage = NSImage(size: NSSize(width: 1, height: 1))
        cursorImage.lockFocus()
        NSColor.clear.set()
        NSRect(origin: .zero, size: NSSize(width: 1, height: 1)).fill()
        cursorImage.unlockFocus()

        let blankCursor = NSCursor(image: cursorImage, hotSpot: .zero)

        // Set up a tracking area covering the entire window
        let view = CursorHidingView(frame: screen.frame, cursor: blankCursor)
        window.contentView = view

        window.orderFront(nil)
        blankWindow = window

        isCursorVisible = false
    }

    private func showCursor() {
        blankWindow?.orderOut(nil)
        blankWindow = nil
        NSCursor.arrow.set()
        isCursorVisible = true
    }
}

private final class CursorHidingView: NSView {
    private let blankCursor: NSCursor

    init(frame: NSRect, cursor: NSCursor) {
        self.blankCursor = cursor
        super.init(frame: frame)

        addTrackingArea(NSTrackingArea(
            rect: bounds,
            options: [.cursorUpdate, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        ))
    }

    required init?(coder: NSCoder) { fatalError() }

    override func cursorUpdate(with event: NSEvent) {
        blankCursor.set()
    }

    override func resetCursorRects() {
        addCursorRect(bounds, cursor: blankCursor)
    }
}
