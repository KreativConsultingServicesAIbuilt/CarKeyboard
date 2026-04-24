import Cocoa

final class CursorManager {
    static let shared = CursorManager()

    private(set) var isCursorVisible = true
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var hideCount = 0

    func toggle() -> Bool {
        if isCursorVisible {
            hideCursor()
        } else {
            showCursor()
        }
        return isCursorVisible
    }

    private func hideCursor() {
        // Use .defaultTap (not .listenOnly) so our callback runs BEFORE
        // macOS processes the event and potentially shows the cursor.
        // Intercept all pointer events — touchscreen generates mouseMoved.
        // Split into two halves so the type-checker doesn't time out
        let moveMask: CGEventMask = (1 << CGEventType.mouseMoved.rawValue)
            | (1 << CGEventType.leftMouseDragged.rawValue)
            | (1 << CGEventType.rightMouseDragged.rawValue)
            | (1 << CGEventType.otherMouseDragged.rawValue)
        let clickMask: CGEventMask = (1 << CGEventType.leftMouseDown.rawValue)
            | (1 << CGEventType.leftMouseUp.rawValue)
            | (1 << CGEventType.rightMouseDown.rawValue)
            | (1 << CGEventType.rightMouseUp.rawValue)
            | (1 << CGEventType.scrollWheel.rawValue)
        let mask: CGEventMask = moveMask | clickMask

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,          // active tap — fires before cursor shows
            eventsOfInterest: mask,
            callback: { _, _, event, _ in
                // Belt-and-suspenders: both APIs
                CGDisplayHideCursor(CGMainDisplayID())
                NSCursor.hide()
                return Unmanaged.passRetained(event)
            },
            userInfo: nil
        ) else { return }

        eventTap = tap
        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        runLoopSource = source
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)

        // Initial hide — call twice to push the hide-level counter above 0
        CGDisplayHideCursor(CGMainDisplayID())
        NSCursor.hide()
        hideCount = 2
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

        // Balance the hide calls (CGDisplayShowCursor is counter-based)
        for _ in 0 ..< hideCount {
            CGDisplayShowCursor(CGMainDisplayID())
        }
        // NSCursor uses its own nested hide counter
        NSCursor.unhide()
        hideCount = 0
        isCursorVisible = true
    }
}
