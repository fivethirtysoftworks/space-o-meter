import Foundation

struct AppPreferences {
    var showPercentageInMenuBar: Bool = false
    var includeExternalVolumes: Bool = true
    var includeNetworkVolumes: Bool = true
    var lowSpaceThresholdGB: Int = 100
    var refreshInterval: TimeInterval = 10
}
