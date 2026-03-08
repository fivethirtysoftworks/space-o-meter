import SwiftUI

@main
struct SpaceOMeterApp: App {
    @StateObject private var monitor = StorageMonitor()
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        MenuBarExtra {
            MenuBarContentView()
                .environmentObject(monitor)
                .frame(width: 360)
                .task {
                    monitor.start()
                }
        } label: {
            MenuBarLabelView()
                .environmentObject(monitor)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environmentObject(monitor)
                .frame(width: 480, height: 430)
        }

        Window("About Space‑O‑Meter", id: "about") {
            AboutView()
        }
        .defaultSize(width: 320, height: 300)

        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About Space‑O‑Meter") {
                    openWindow(id: "about")
                }
            }
        }
    }
}
