import Foundation
import Combine

@MainActor
final class StorageMonitor: ObservableObject {
    @Published var localDisk: VolumeSnapshot?
    @Published var networkVolumes: [VolumeSnapshot] = []
    @Published var externalVolumes: [VolumeSnapshot] = []
    @Published var preferences = AppPreferences()
    @Published var lastUpdated = Date()

    private var timer: Timer?

    func updatePreferences(_ new: AppPreferences) {
        preferences = new
        configureTimer()
        refresh()
        #if DEBUG
        print("[StorageMonitor] Preferences updated. Refresh interval: \(preferences.refreshInterval), includeExternal: \(preferences.includeExternalVolumes), includeNetwork: \(preferences.includeNetworkVolumes)")
        #endif
    }

    // MARK: - Convenience accessors for UI (Option A: use freeBytes for "Free")
    func freeBytes(for snapshot: VolumeSnapshot?) -> Int64 {
        snapshot?.freeBytes ?? 0
    }

    func freeBytesForLocalDisk() -> Int64 {
        freeBytes(for: localDisk)
    }

    func freeBytesForNetworkVolumes() -> [String: Int64] {
        var map: [String: Int64] = [:]
        for v in networkVolumes {
            map[v.id] = v.freeBytes
        }
        return map
    }

    func freeBytesForExternalVolumes() -> [String: Int64] {
        var map: [String: Int64] = [:]
        for v in externalVolumes {
            map[v.id] = v.freeBytes
        }
        return map
    }

    // MARK: - Formatted "Free" strings for UI
    private lazy var byteCountFormatter: ByteCountFormatter = {
        let f = ByteCountFormatter()
        f.allowedUnits = .useAll
        f.countStyle = .file
        return f
    }()

    func formattedFree(for snapshot: VolumeSnapshot?) -> String {
        byteCountFormatter.string(fromByteCount: freeBytes(for: snapshot))
    }

    func formattedFreeForLocalDisk() -> String {
        formattedFree(for: localDisk)
    }

    func formattedFreeForNetworkVolumes() -> [String: String] {
        var map: [String: String] = [:]
        for v in networkVolumes {
            map[v.id] = byteCountFormatter.string(fromByteCount: v.freeBytes)
        }
        return map
    }

    func formattedFreeForExternalVolumes() -> [String: String] {
        var map: [String: String] = [:]
        for v in externalVolumes {
            map[v.id] = byteCountFormatter.string(fromByteCount: v.freeBytes)
        }
        return map
    }

    func start() {
        refresh()
        configureTimer()
        #if DEBUG
        print("[StorageMonitor] Started monitoring. Interval: \(preferences.refreshInterval)s")
        #endif
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        #if DEBUG
        print("[StorageMonitor] Stopped monitoring")
        #endif
    }

    func configureTimer() {
        stop()

        #if DEBUG
        print("[StorageMonitor] Configuring timer with interval: \(preferences.refreshInterval)s")
        #endif

        timer = Timer.scheduledTimer(withTimeInterval: preferences.refreshInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refresh()
            }
        }

        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    func refresh() {
        #if DEBUG
        print("[StorageMonitor] Refreshing volumes at \(Date())")
        #endif

        let volumes = VolumeScanner.scan(
            includeExternal: preferences.includeExternalVolumes,
            includeNetwork: preferences.includeNetworkVolumes
        )

        // Prefer the true internal root volume mounted at "/"
        let internalRoot = volumes.first(where: { $0.isInternal && !$0.isRemovable && !$0.isNetwork && $0.path == "/" })
        // Fallback: any internal, local, non-removable volume
        let internalAny = volumes.first(where: { $0.isInternal && !$0.isRemovable && !$0.isNetwork })
        // Last resort: previous behavior — any local, non-network, non-removable
        let localFallback = volumes.first(where: { !$0.isNetwork && !$0.isRemovable })
        localDisk = internalRoot ?? internalAny ?? localFallback
        #if DEBUG
        if localDisk?.path == "/" {
            print("[StorageMonitor] localDisk selected: internal root — \(localDisk?.name ?? "?")")
        } else if localDisk?.isInternal == true {
            print("[StorageMonitor] localDisk selected: internal non-root — \(localDisk?.name ?? "?")")
        } else {
            print("[StorageMonitor] localDisk selected: fallback — \(localDisk?.name ?? "?")")
        }
        #endif

        networkVolumes = volumes.filter { $0.isNetwork }
        externalVolumes = volumes.filter { !$0.isNetwork && !$0.isInternal }
        lastUpdated = Date()

        #if DEBUG
        let localName = localDisk?.name ?? "nil"
        let networkNames = networkVolumes.map { $0.name }
        let externalNames = externalVolumes.map { $0.name }
        print("[StorageMonitor] Refresh complete — local: \(localName), network(\(networkVolumes.count)): \(networkNames), external(\(externalVolumes.count)): \(externalNames), updated: \(lastUpdated)")
        #endif
    }
}

