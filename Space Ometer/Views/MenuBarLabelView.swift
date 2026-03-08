import SwiftUI

struct MenuBarLabelView: View {
    @EnvironmentObject private var monitor: StorageMonitor

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "internaldrive")
                .font(.system(size: 12, weight: .semibold))

            if let disk = monitor.localDisk {
                if monitor.preferences.showPercentageInMenuBar {
                    Text("\(Int(disk.usedFraction * 100))%")
                        .monospacedDigit()
                } else {
                    Text(ByteFormatters.compact(disk.freeBytes))
                        .monospacedDigit()
                }
            } else {
                Text("--")
                    .monospacedDigit()
            }
        }
    }
}
