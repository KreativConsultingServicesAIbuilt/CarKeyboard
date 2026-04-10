import Cocoa

final class CursorManager {
    static let shared = CursorManager()

    private(set) var isCursorVisible = true
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    func toggle() -> Bool {
        if isCursorVisible {
            hideCursor()
        } else {
            showCursor()
        }
        return isCursorVisible
    }

    private func hideCursor() {
        // Install a CGEvent tap that intercepts cursor movements
        // and suppresses the system cursor by hiding it on every move
        let mask: CGEventMask = (1 << CGEventType.mouseMoved.rawValue)
            | (1 << CGEventType.leftMouseDragged.rawValue)
            | (1 << CGEventType.rightMouseDragged.rawValue)
            | (1 << CGEventType.leftMouseDown.rawValue)
            | (1 << CGEventType.leftMouseUp.rawValue)

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: mask,
            callback: { _, _, event, _ in
                CGDisplayHideCursor(CGMainDisplayID())
                return Unmanaged.passRetained(event)
            },
            userInfo: nil
        ) else { return }

        eventTap = tap
        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        runLoopSource = source
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)

        // Initial hide
        CGDisplayHideCursor(CGMainDisplayID())
        isCursorVisible = false
    }

    private func showCursor() {
        // Remove event tap
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
        }
        eventTap = nil
        runLoopSource = nil

        // Show cursor
        CGDisplayShowCursor(CGMainDisplayID())
        isCursorVisible = true
    }
}
