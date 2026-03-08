import SwiftUI

struct VolumeCard: View {
    let title: String
    let volume: VolumeSnapshot

    private var usageColor: Color {
        let used = volume.usedFraction
        switch used {
        case ..<0.70: return .green
        case 0.70..<0.90: return .orange
        default: return .red
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(title, systemImage: volume.iconSymbol)
                    .font(.system(size: 13, weight: .semibold))

                Spacer()

                Text("\(Int((volume.usedFraction * 100).rounded()))%")
                    .accessibilityLabel("Used \(Int((volume.usedFraction * 100).rounded())) percent")
                    .font(.system(size: 14, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(usageColor)
            }

            ProgressView(value: volume.usedFraction)
                .tint(usageColor)
                .progressViewStyle(.linear)

            HStack(spacing: 12) {
                StatPill(title: "Used", value: ByteFormatters.compact(volume.usedBytes))
                    .foregroundStyle(usageColor)
                StatPill(title: "Free", value: ByteFormatters.compact(volume.freeBytes))
                StatPill(title: "Total", value: ByteFormatters.compact(volume.totalBytes))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
    }
}

private struct StatPill: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .monospacedDigit()
                .accessibilityLabel("\(title) \(value)")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.primary.opacity(0.05))
        )
    }
}

