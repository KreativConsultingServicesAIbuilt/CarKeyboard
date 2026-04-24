import Cocoa

/// A sleek vertical tab on the right edge of the screen, vertically centered.
/// Tapping it toggles the keyboard.
final class EdgeTabWindow: NSPanel {
    var onTap: (() -> Void)?

    private let tabWidth: CGFloat = 28
    private let tabHeight: CGFloat = 80

    init() {
        guard let screen = NSScreen.main else {
            super.init(
                contentRect: NSRect(x: 0, y: 0, width: 28, height: 80),
                styleMask: [.nonactivatingPanel, .borderless],
                backing: .buffered,
                defer: false
            )
            return
        }

        let screenFrame = screen.visibleFrame
        let x = screenFrame.maxX - 28
        let y = screenFrame.midY - 40

        super.init(
            contentRect: NSRect(x: x, y: y, width: 28, height: 80),
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )

        // Must be above the keyboard panel (.popUpMenu = 101) so it's always tappable
        level = NSWindow.Level(rawValue: NSWindow.Level.popUpMenu.rawValue + 1)
        isFloatingPanel = true
        becomesKeyOnlyIfNeeded = true
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        let tabView = EdgeTabView(frame: NSRect(x: 0, y: 0, width: 28, height: 80))
        tabView.onTap = { [weak self] in self?.onTap?() }
        contentView = tabView
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

private final class EdgeTabView: NSView {
    var onTap: (() -> Void)?
    private var isHovered = false

    override init(frame: NSRect) {
        super.init(frame: frame)
        addTrackingArea(NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeAlways],
            owner: self,
            userInfo: nil
        ))
    }

    required init?(coder: NSCoder) { fatalError() }

    override func draw(_ dirtyRect: NSRect) {
        // Rounded pill shape, only left corners rounded (hugs right edge)
        let path = NSBezierPath(
            roundedRect: NSRect(x: 0, y: 0, width: bounds.width, height: bounds.height),
            xRadius: 12,
            yRadius: 12
        )

        let bgAlpha: CGFloat = isHovered ? 0.95 : 0.7
        NSColor(red: 0.25, green: 0.35, blue: 0.55, alpha: bgAlpha).setFill()
        path.fill()

        // Subtle border
        NSColor.white.withAlphaComponent(0.15).setStroke()
        path.lineWidth = 0.5
        path.stroke()

        // Draw chevron arrow (◀) pointing left
        let chevronFont = NSFont.systemFont(ofSize: 16, weight: .semibold)
        let chevron = "◀" as NSString
        let attrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.white.withAlphaComponent(isHovered ? 1.0 : 0.7),
            .font: chevronFont,
        ]
        let size = chevron.size(withAttributes: attrs)
        let point = NSPoint(
            x: (bounds.width - size.width) / 2,
            y: (bounds.height - size.height) / 2
        )
        chevron.draw(at: point, withAttributes: attrs)
    }

    override func mouseEntered(with event: NSEvent) {
        isHovered = true
        needsDisplay = true
    }

    override func mouseExited(with event: NSEvent) {
        isHovered = false
        needsDisplay = true
    }

    override func mouseDown(with event: NSEvent) {
        onTap?()
    }
}
