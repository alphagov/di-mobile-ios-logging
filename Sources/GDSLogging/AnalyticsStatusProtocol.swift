import Foundation

/// AnalyticsStatusProtocol
///
/// A protocol for Types to check if analytics permissions have been enabled
@available(*, deprecated, renamed: "AnalyticsPreferenceStore")
public protocol AnalyticsStatusProtocol {
    var hasAcceptedAnalytics: Bool? { get set }
}

// TODO: DCMAW-5991 Unit tests for AnalyticsStatusProtocol
extension UserDefaults: AnalyticsStatusProtocol {
    /// Checks if user has been asked for analytics permissions then gets the set analytics permissions
    /// Sets the permissions when given one
    public var hasAcceptedAnalytics: Bool? {
        get {
            guard hasAskedForAnalyticsPermissions() else {
                return nil
            }
            return fetchStatus()
        }
        set {
            guard let status = newValue else { return }
            storeStatus(hasAcceptedAnalytics: status)
        }
    }
    
    /// Checks User Defaults for value assigned to `hasAskedForAnalyticsPermissions` key
    private func hasAskedForAnalyticsPermissions() -> Bool {
        bool(forKey: "hasAskedForAnalyticsPermissions")
    }
    
    /// Checks User Defaults for value assigned to `hasAcceptedAnalytics` key
    private func fetchStatus() -> Bool {
        bool(forKey: "hasAcceptedAnalytics")
    }
    
    /// Sets value for `hasAskedForAnalyticsPermissions` key to true
    /// Sets value for `hasAcceptedAnalytics` key
    private func storeStatus(hasAcceptedAnalytics: Bool) {
        set(true, forKey: "hasAskedForAnalyticsPermissions")
        set(hasAcceptedAnalytics, forKey: "hasAcceptedAnalytics")
    }
}
