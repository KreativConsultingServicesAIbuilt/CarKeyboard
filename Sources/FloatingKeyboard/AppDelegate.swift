import Cocoa
import ServiceManagement
import SwiftUI

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

        // Check accessibility permission
        checkAccessibility()
    }

    private var keyboardWidth: CGFloat {
        guard let screen = NSScreen.main else { return 800 }
        return screen.visibleFrame.width
    }

    private var keyboardHeight: CGFloat {
        guard let screen = NSScreen.main else { return 300 }
        return min(screen.visibleFrame.height / 3, 350)
    }

    private func setupKeyboardPanel() {
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        let w = keyboardWidth
        let h = keyboardHeight

        // Position at bottom, full width, initially off-screen (below)
        let x = screenFrame.minX
        let y = screenFrame.minY - h

        let rect = NSRect(x: x, y: y, width: w, height: h)
        keyboardPanel = KeyboardPanel(contentRect: rect)

        let hostView = NSHostingView(rootView: KeyboardView())
        keyboardPanel.contentView = hostView

        keyboardPanel.orderFront(nil)
    }

    private func setupEdgeTab() {
        edgeTab = EdgeTabWindow()
        edgeTab.onTap = { [weak self] in
            self?.toggleKeyboard()
        }
        edgeTab.orderFront(nil)
    }

    private func toggleKeyboard() {
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        let w = keyboardWidth
        let h = keyboardHeight
        let x = screenFrame.minX

        if isKeyboardVisible {
            // Slide down (hide)
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.25
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                keyboardPanel.animator().setFrame(
                    NSRect(x: x, y: screenFrame.minY - h, width: w, height: h),
                    display: true
                )
            })
        } else {
            // Slide up (show) — just above the dock
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.25
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                keyboardPanel.animator().setFrame(
                    NSRect(x: x, y: screenFrame.minY, width: w, height: h),
                    display: true
                )
            })
        }

        isKeyboardVisible.toggle()
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
