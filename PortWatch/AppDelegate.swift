import AppKit
import SwiftUI
import Combine

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private let portScanner = PortScanner()
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupPopover()
        bindPortScanner()
        portScanner.startAutoRefresh(interval: 5.0)
    }

    func applicationWillTerminate(_ notification: Notification) {
        portScanner.stopAutoRefresh()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "network", accessibilityDescription: "Port Watch")
            button.imagePosition = .imageLeading
            button.title = "0"
            button.action = #selector(togglePopover)
            button.target = self
        }
    }

    private func setupPopover() {
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 300, height: 400)
        popover?.behavior = .transient
        popover?.animates = true
        popover?.contentViewController = NSHostingController(
            rootView: MenuView(scanner: portScanner)
        )
    }

    private func bindPortScanner() {
        portScanner.$totalPortCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                self?.updateStatusBarTitle(count: count)
            }
            .store(in: &cancellables)
    }

    private func updateStatusBarTitle(count: Int) {
        statusItem?.button?.title = "\(count)"
    }

    @objc private func togglePopover() {
        guard let button = statusItem?.button, let popover = popover else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
