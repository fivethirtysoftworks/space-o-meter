import Foundation

struct VolumeSnapshot: Identifiable, Equatable {
    let id: String
    let name: String
    let path: String
    let totalBytes: Int64
    let freeBytes: Int64
    let availableBytes: Int64
    let isNetwork: Bool
    let isRemovable: Bool
    let isInternal: Bool
    let iconSymbol: String

    var usedBytes: Int64 {
        max(totalBytes - freeBytes, 0)
    }

    var usedFraction: Double {
        guard totalBytes > 0 else { return 0 }
        return Double(usedBytes) / Double(totalBytes)
    }

    var subtitle: String {
        "\(ByteFormatters.standard(freeBytes)) free of \(ByteFormatters.standard(totalBytes))"
    }
}
