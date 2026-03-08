import SwiftUI
import AppKit

struct MenuBarContentView: View {
    @EnvironmentObject private var monitor: StorageMonitor
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Space-O-Meter")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Updated \(monitor.lastUpdated.formatted(date: .omitted, time: .standard))")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    monitor.refresh()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.plain)
            }

            if let disk = monitor.localDisk {
                VolumeCard(title: "Disk", volume: disk)
            }

            if !monitor.networkVolumes.isEmpty {
                HStack {
                    Text("NETWORK DISKS")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(monitor.networkVolumes.count)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                }

                ForEach(monitor.networkVolumes) { volume in
                    VolumeCard(title: volume.name, volume: volume)
                }
            }

            if !monitor.externalVolumes.isEmpty {
                HStack {
                    Text("EXTERNAL DISKS")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(monitor.externalVolumes.count)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                }

                ForEach(monitor.externalVolumes) { volume in
                    VolumeCard(title: volume.name, volume: volume)
                }
            }

            Divider()

            HStack {
                Button("Open Disk Utility") {
                    let url = URL(fileURLWithPath: "/System/Applications/Utilities/Disk Utility.app")
                    NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration()) { _, _ in }
                }
                .buttonStyle(.link)

                Spacer()

                Button("Settings") {
                    openSettings()
                }
                .buttonStyle(.link)

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.link)
            }
            .font(.system(size: 12, weight: .medium))
        }
        .padding(14)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}
