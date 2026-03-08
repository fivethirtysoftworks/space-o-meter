import SwiftUI
import AppKit

struct AboutView: View {

    var body: some View {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"

        VStack(spacing: 16) {

            Image("AboutIcon")
                .resizable()
                .frame(width: 64, height: 64)

            Text("Space-O-Meter")
                .font(.title2)
                .bold()

            Text("A lightweight disk monitoring utility for macOS.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Text("Version \(version) (\(build))")

            Divider()

            Text("Created by Cornelius Faulder")
                .font(.footnote)
            
            Link("fivethirtysoftworks.github.io/space-o-meter/",
                 destination: URL(string: "https://fivethirtysoftworks.github.io/space-o-meter/")!)
                .font(.footnote)

            Button("Copy Diagnostics") {
                let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Space-O-Meter"
                let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? version
                let appBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? build
                let osVersion = ProcessInfo.processInfo.operatingSystemVersion
                let osString = "macOS \(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"

                var lines: [String] = []
                lines.append("App: \(appName)")
                lines.append("Version: \(appVersion) (\(appBuild))")
                lines.append(osString)
                lines.append("Locale: \(Locale.current.identifier)")

                let diagnostics = lines.joined(separator: "\n")

                let pb = NSPasteboard.general
                pb.clearContents()
                pb.setString(diagnostics, forType: .string)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)

            Text("© 2026 Space-O-Meter. A Fivethirty Softworks App. All rights reserved. Made in West Virginia. Coded by Sasquatch. Trademark Notice: macOS is a trademark of Apple Inc. All other trademarks are the property of their respective owners. Space-O-Meter by Fivethirty Softworks is not affiliated with or endorsed by these companies.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 520)
        }
        .padding(30)
        .frame(width: 620)
    }
}
