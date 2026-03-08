import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var monitor: StorageMonitor

    var body: some View {
        Form {
            Section("Menu Bar") {
                Toggle("Show percentage instead of free space", isOn: percentageBinding)
            }

            Section("Volumes") {
                Toggle("Include external volumes", isOn: externalBinding)
                Toggle("Include network volumes", isOn: networkBinding)
            }

            Section("Monitoring") {
                Stepper(value: thresholdBinding, in: 10...1000, step: 10) {
                    Text("Low space threshold: \(monitor.preferences.lowSpaceThresholdGB) GB")
                }

                Picker("Refresh interval", selection: intervalBinding) {
                    Text("5 seconds").tag(TimeInterval(5))
                    Text("10 seconds").tag(TimeInterval(10))
                    Text("30 seconds").tag(TimeInterval(30))
                    Text("60 seconds").tag(TimeInterval(60))
                }
            }

            Section("Notes") {
                Text("Network disk monitoring only works for volumes already mounted in macOS.")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    private var percentageBinding: Binding<Bool> {
        Binding(
            get: { monitor.preferences.showPercentageInMenuBar },
            set: { newValue in
                monitor.preferences.showPercentageInMenuBar = newValue
            }
        )
    }

    private var externalBinding: Binding<Bool> {
        Binding(
            get: { monitor.preferences.includeExternalVolumes },
            set: { newValue in
                monitor.preferences.includeExternalVolumes = newValue
                monitor.refresh()
            }
        )
    }

    private var networkBinding: Binding<Bool> {
        Binding(
            get: { monitor.preferences.includeNetworkVolumes },
            set: { newValue in
                monitor.preferences.includeNetworkVolumes = newValue
                monitor.refresh()
            }
        )
    }

    private var thresholdBinding: Binding<Int> {
        Binding(
            get: { monitor.preferences.lowSpaceThresholdGB },
            set: { newValue in
                monitor.preferences.lowSpaceThresholdGB = newValue
            }
        )
    }

    private var intervalBinding: Binding<TimeInterval> {
        Binding(
            get: { monitor.preferences.refreshInterval },
            set: { newValue in
                monitor.preferences.refreshInterval = newValue
                monitor.configureTimer()
            }
        )
    }
}
