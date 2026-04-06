import Cocoa
import ServiceManagement
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var keyboardPanel: KeyboardPanel!
    private var edgeTab: EdgeTabWindow!
    private var isKeyboardVisible = false

    private let keyboardWidth: CGFloat = 630
    private let keyboardHeight: CGFloat = 320

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon — app lives in the floating panels only
        NSApp.setActivationPolicy(.accessory)

        setupKeyboardPanel()
        setupEdgeTab()

        // Register as login item (launch at startup)
        try? SMAppService.mainApp.register()

        // Check accessibility permission
        checkAccessibility()
    }

    private func setupKeyboardPanel() {
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame

        // Position at bottom center, initially off-screen (below)
        let x = screenFrame.midX - keyboardWidth / 2
        let y = screenFrame.minY - keyboardHeight

        let rect = NSRect(x: x, y: y, width: keyboardWidth, height: keyboardHeight)
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

        let x = screenFrame.midX - keyboardWidth / 2

        if isKeyboardVisible {
            // Slide down (hide)
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.25
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                keyboardPanel.animator().setFrame(
                    NSRect(x: x, y: screenFrame.minY - keyboardHeight,
                           width: keyboardWidth, height: keyboardHeight),
                    display: true
                )
            })
            // Move edge tab back to bottom
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.25
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                let tabFrame = edgeTab.frame
                edgeTab.animator().setFrame(
                    NSRect(x: tabFrame.origin.x, y: screenFrame.minY,
                           width: tabFrame.width, height: tabFrame.height),
                    display: true
                )
            })
        } else {
            // Slide up (show)
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.25
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                keyboardPanel.animator().setFrame(
                    NSRect(x: x, y: screenFrame.minY,
                           width: keyboardWidth, height: keyboardHeight),
                    display: true
                )
            })
            // Move edge tab above keyboard
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.25
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                let tabFrame = edgeTab.frame
                edgeTab.animator().setFrame(
                    NSRect(x: tabFrame.origin.x, y: screenFrame.minY + keyboardHeight,
                           width: tabFrame.width, height: tabFrame.height),
                    display: true
                )
            })
        }

        isKeyboardVisible.toggle()
    }

    private func checkAccessibility() {
        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue(): true] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)
        if !trusted {
            print("⚠️  Accessibility permission required. Please grant it in System Settings > Privacy & Security > Accessibility.")
        }
    }
}
