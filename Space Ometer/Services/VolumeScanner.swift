import Foundation

enum VolumeScanner {
    static func scan(includeExternal: Bool, includeNetwork: Bool) -> [VolumeSnapshot] {
        let keys: Set<URLResourceKey> = [
            .volumeNameKey,
            .volumeTotalCapacityKey,
            .volumeAvailableCapacityKey,
            .volumeAvailableCapacityForImportantUsageKey,
            .volumeIsInternalKey,
            .volumeIsLocalKey,
            .volumeIsRemovableKey,
            .volumeIsEjectableKey,
            .isVolumeKey
        ]

        guard let urls = FileManager.default.mountedVolumeURLs(
            includingResourceValuesForKeys: Array(keys),
            options: [.skipHiddenVolumes]
        ) else {
            return []
        }

        return urls.compactMap { (url) -> VolumeSnapshot? in
            guard let values = try? url.resourceValues(forKeys: keys),
                  values.isVolume == true else {
                return nil
            }

            // Primary values from URLResourceValues (Int? coerced to Int64)
            var totalBytes: Int64 = (values.volumeTotalCapacity.map { Int64($0) }) ?? 0
            var availableBytes: Int64 = (
                values.volumeAvailableCapacityForImportantUsage.map { Int64($0) }
                ?? values.volumeAvailableCapacity.map { Int64($0) }
            ) ?? 0
            var freeBytes: Int64 = (values.volumeAvailableCapacity.map { Int64($0) }) ?? availableBytes

            // Fallback: If totals/available look zero, try FileManager.attributesOfFileSystem
            if totalBytes == 0 || (availableBytes == 0 && freeBytes == 0) {
                if let attrs = try? FileManager.default.attributesOfFileSystem(forPath: url.path) {
                    let fsTotal = (attrs[.systemSize] as? NSNumber)?.int64Value ?? 0
                    let fsFree = (attrs[.systemFreeSize] as? NSNumber)?.int64Value ?? 0
                    if totalBytes == 0 { totalBytes = fsTotal }
                    if availableBytes == 0 { availableBytes = fsFree }
                    if freeBytes == 0 { freeBytes = fsFree }
                }
            }

            let isLocal = values.volumeIsLocal ?? true
            let isInternal = values.volumeIsInternal ?? false
            let isRemovable = (values.volumeIsRemovable ?? false) || (values.volumeIsEjectable ?? false)
            let isNetwork = !isLocal

            #if DEBUG
            print("[VolumeScanner] Found volume — name: \(values.volumeName ?? url.lastPathComponent), path: \(url.path), total: \(totalBytes), available: \(availableBytes), free: \(freeBytes), isInternal: \(isInternal), isLocal: \(isLocal), isRemovable: \(isRemovable), isNetwork: \(isNetwork)")
            #endif

            guard totalBytes > 0 else { return nil }
            if isNetwork && !includeNetwork { return nil }
            if !isNetwork && isRemovable && !includeExternal { return nil }

            let iconSymbol: String
            if isNetwork {
                iconSymbol = "externaldrive.connected.to.line.below"
            } else if isInternal {
                iconSymbol = "internaldrive"
            } else {
                iconSymbol = "externaldrive"
            }

            return VolumeSnapshot(
                id: url.path,
                name: values.volumeName ?? url.lastPathComponent,
                path: url.path,
                totalBytes: totalBytes,
                freeBytes: freeBytes,
                availableBytes: availableBytes,
                isNetwork: isNetwork,
                isRemovable: isRemovable,
                isInternal: isInternal,
                iconSymbol: iconSymbol
            )
        }
        .sorted { lhs, rhs in
            switch (lhs.isNetwork, rhs.isNetwork) {
            case (false, true):
                return true
            case (true, false):
                return false
            default:
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
        }
    }
}
