import Cocoa

/// A tiny always-visible tab at the bottom center of the screen.
/// Tapping it toggles the keyboard.
final class EdgeTabWindow: NSPanel {
    var onTap: (() -> Void)?

    init() {
        let tabWidth: CGFloat = 80
        let tabHeight: CGFloat = 24

        guard let screen = NSScreen.main else {
            super.init(
                contentRect: NSRect(x: 0, y: 0, width: tabWidth, height: tabHeight),
                styleMask: [.nonactivatingPanel, .borderless],
                backing: .buffered,
                defer: false
            )
            return
        }

        let screenFrame = screen.visibleFrame
        let x = screenFrame.midX - tabWidth / 2
        let y = screenFrame.minY

        super.init(
            contentRect: NSRect(x: x, y: y, width: tabWidth, height: tabHeight),
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )

        level = .floating
        isFloatingPanel = true
        becomesKeyOnlyIfNeeded = true
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        let tabView = EdgeTabView(frame: NSRect(x: 0, y: 0, width: tabWidth, height: tabHeight))
        tabView.onTap = { [weak self] in self?.onTap?() }
        contentView = tabView
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

private final class EdgeTabView: NSView {
    var onTap: (() -> Void)?

    override func draw(_ dirtyRect: NSRect) {
        let path = NSBezierPath(
            roundedRect: bounds,
            xRadius: 8,
            yRadius: 8
        )
        NSColor(white: 0.15, alpha: 0.9).setFill()
        path.fill()

        // Draw a small keyboard icon / chevron
        let text = "⌨︎" as NSString
        let attrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.white.withAlphaComponent(0.8),
            .font: NSFont.systemFont(ofSize: 14, weight: .medium),
        ]
        let size = text.size(withAttributes: attrs)
        let point = NSPoint(
            x: (bounds.width - size.width) / 2,
            y: (bounds.height - size.height) / 2
        )
        text.draw(at: point, withAttributes: attrs)
    }

    override func mouseDown(with event: NSEvent) {
        onTap?()
    }
}
