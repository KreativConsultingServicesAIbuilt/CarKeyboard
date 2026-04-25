import Cocoa
import ServiceManagement
import SwiftUI

extension Notification.Name {
    static let hideKeyboard = Notification.Name("FloatingKeyboard.hide")
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var keyboardPanel: KeyboardPanel!
    private var edgeTab: EdgeTabWindow!
    private var statusItem: NSStatusItem!
    private var isKeyboardVisible = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon — app lives in the floating panels only
        NSApp.setActivationPolicy(.accessory)

        setupKeyboardPanel()
        setupEdgeTab()
        setupMenuBar()

        // Register as login item (launch at startup)
        try? SMAppService.mainApp.register()

        // "Göm" button inside KeyboardView posts this to hide the keyboard
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hideKeyboardFromNotification),
            name: .hideKeyboard,
            object: nil
        )

        // Check accessibility permission
        checkAccessibility()
    }

    // Full-screen dimensions — covers entire display including menu bar
    private var keyboardFrame: NSRect {
        guard let screen = NSScreen.main else {
            return NSRect(x: 0, y: 0, width: 1280, height: 800)
        }
        return screen.frame
    }

    private func setupKeyboardPanel() {
        let sf = keyboardFrame
        // Start off-screen below the display
        let rect = NSRect(x: sf.minX, y: sf.minY - sf.height,
                          width: sf.width, height: sf.height)
        keyboardPanel = KeyboardPanel(contentRect: rect)

        let hostView = NSHostingView(rootView: KeyboardView())
        keyboardPanel.contentView = hostView

        // Start hidden — don't show until toggled
        keyboardPanel.orderOut(nil)
    }

    private func setupEdgeTab() {
        edgeTab = EdgeTabWindow()
        edgeTab.onTap = { [weak self] in
            self?.toggleKeyboard()
        }
        edgeTab.orderFront(nil)
    }

    private func toggleKeyboard() {
        let sf = keyboardFrame
        let shown  = NSRect(x: sf.minX, y: sf.minY, width: sf.width, height: sf.height)
        let hidden = NSRect(x: sf.minX, y: sf.minY - sf.height, width: sf.width, height: sf.height)

        if isKeyboardVisible {
            // Slide down then hide completely
            keyboardPanel.setFrame(shown, display: false)
            NSAnimationContext.runAnimationGroup({ ctx in
                ctx.duration = 0.25
                ctx.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                keyboardPanel.animator().setFrame(hidden, display: true)
            }, completionHandler: { [weak self] in
                self?.keyboardPanel.orderOut(nil)
            })
            isKeyboardVisible = false
        } else {
            // Position off-screen, show, then slide up
            keyboardPanel.setFrame(hidden, display: false)
            keyboardPanel.orderFront(nil)
            NSAnimationContext.runAnimationGroup({ ctx in
                ctx.duration = 0.25
                ctx.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                keyboardPanel.animator().setFrame(shown, display: true)
            })
            isKeyboardVisible = true
        }
    }

    @objc private func hideKeyboardFromNotification() {
        guard isKeyboardVisible else { return }
        toggleKeyboard()
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.title = "⌨"
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Toggle Keyboard", action: #selector(menuToggle), keyEquivalent: "k"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Floating Keyboard", action: #selector(menuQuit), keyEquivalent: "q"))
        statusItem.menu = menu
    }

    @objc private func menuToggle() {
        toggleKeyboard()
    }

    @objc private func menuQuit() {
        NSApp.terminate(nil)
    }

    private func checkAccessibility() {
        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue(): true] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)
        if !trusted {
            print("⚠️  Accessibility permission required. Please grant it in System Settings > Privacy & Security > Accessibility.")
        }
    }
}
