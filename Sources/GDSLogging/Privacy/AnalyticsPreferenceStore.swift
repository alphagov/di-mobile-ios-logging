import Foundation

public protocol AnalyticsPreferenceStore {
    var hasAcceptedAnalytics: Bool? { get set }
    func stream() -> AsyncStream<Bool>
}

public final class UserDefaultsPreferenceStore: AnalyticsPreferenceStore {
    private let defaults: UserDefaults
    private var subscribers: [AsyncStream<Bool>.Continuation] = []
    
    init(defaults: UserDefaults) {
        self.defaults = defaults
        
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(valueDidChange),
                         name: UserDefaults.didChangeNotification,
                         object: nil)
    }
    
    public var hasAcceptedAnalytics: Bool? {
        get {
            guard value(for: .hasAskedForAnalyticsPermissions) else {
                return nil
            }
            return value(for: .hasAcceptedAnalytics)
        }
        set {
            if let newValue {
                defaults.set(true, forKey: DefaultsKey.hasAskedForAnalyticsPermissions.rawValue)
                defaults.set(newValue, forKey: DefaultsKey.hasAcceptedAnalytics.rawValue)
            } else {
                defaults.set(false, forKey: DefaultsKey.hasAskedForAnalyticsPermissions.rawValue)
                defaults.set(false, forKey: DefaultsKey.hasAcceptedAnalytics.rawValue)
            }
        }
    }
    
    public convenience init() {
        self.init(defaults: .standard)
    }
    
    @objc private func valueDidChange() {
        guard let newValue = hasAcceptedAnalytics else { return }
        subscribers.forEach {
            $0.yield(newValue)
        }
    }
    
    private func value(for key: DefaultsKey) -> Bool {
        defaults.bool(forKey: key.rawValue)
    }
    
    public func stream() -> AsyncStream<Bool> {
        AsyncStream { subscriber in
            subscribers.append(subscriber)
        }
    }
    
    private enum DefaultsKey: String {
        case hasAskedForAnalyticsPermissions
        case hasAcceptedAnalytics
    }
}
