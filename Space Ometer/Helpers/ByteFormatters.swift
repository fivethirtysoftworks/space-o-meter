import Foundation

enum ByteFormatters {
    private static let standardFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB, .useTB]
        formatter.countStyle = .file
        formatter.includesUnit = true
        formatter.isAdaptive = true
        return formatter
    }()

    private static let compactFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useTB, .useMB]
        formatter.countStyle = .file
        formatter.includesUnit = true
        formatter.isAdaptive = true
        return formatter
    }()

    static func standard(_ bytes: Int64) -> String {
        standardFormatter.string(fromByteCount: bytes)
    }

    static func compact(_ bytes: Int64) -> String {
        compactFormatter.string(fromByteCount: bytes)
    }
}
