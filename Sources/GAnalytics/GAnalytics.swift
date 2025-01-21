import Firebase
import FirebaseAnalytics
import FirebaseCrashlytics
import GDSLogging

/// GAnalytics
///
/// An abstraction class for bringing Google Analytics (Firebase and Crashlytics) into the app from the Firebase package.
/// To provide user-specific insights for logging app metrics and performance.
public class GAnalytics {
    private let app: AnalyticsApp.Type
    private let analytics: AnalyticsLogger.Type
    private let crashLogger: CrashLogger
    private let preferenceStore: AnalyticsPreferenceStore
    
    /// Additional parameters for the application
    public var additionalParameters = [String: Any]()
    
    init(app: AnalyticsApp.Type,
         analytics: AnalyticsLogger.Type,
         crashLogger: CrashLogger,
         preferenceStore: AnalyticsPreferenceStore) {
        self.app = app
        self.analytics = analytics
        self.crashLogger = crashLogger
        self.preferenceStore = preferenceStore
    }
    
    public convenience init() {
        self.init(app: FirebaseApp.self,
                  analytics: Analytics.self,
                  crashLogger: Crashlytics.crashlytics(),
                  preferenceStore: UserDefaultsPreferenceStore())
    }
    
    /// Initialises the Firebase instance when launching the app.
    public func configure() {
        app.configure()
        subscribeToPreferenceStore()
        updateAnalyticsPreference(preferenceStore.hasAcceptedAnalytics)
    }
    
    private func subscribeToPreferenceStore() {
        Task {
            for await value in preferenceStore.stream() {
                updateAnalyticsPreference(value)
            }
        }
    }
    
    private func updateAnalyticsPreference(_ preference: Bool?) {
        switch preference {
        case true:
            grantAnalyticsPermission()
        default:
            denyAnalyticsPermission()
        }
    }
    
    /// Merging `parameters` dictionary parameter with `additionalParameters` property
    private func mergeAdditionalParameters(_ parameters: [String: Any]) -> [String: Any] {
        additionalParameters.merging(parameters) { $1 }
    }
}

extension GAnalytics: AnalyticsService {
    /// Tracks screens adding screen tracking parameters in Firebase package.
    public func trackScreen(_ screen: LoggableScreen,
                            parameters params: [String: Any] = [:]) {
        var parameters = mergeAdditionalParameters(params)
        
        parameters[AnalyticsParameterScreenName] = screen.name
        parameters[AnalyticsParameterScreenClass] = screen.name
        
        analytics.logEvent(AnalyticsEventScreenView,
                           parameters: parameters)
    }
    
    public func trackScreen(_ screen: LoggableScreenV2,
                            parameters params: [String: Any]) {
        var parameters = mergeAdditionalParameters(params)
        
        parameters[AnalyticsParameterScreenClass] = screen.type.name
        parameters[AnalyticsParameterScreenName] = screen.name
        
        analytics.logEvent(AnalyticsEventScreenView,
                           parameters: parameters)
    }
    
    /// Logs events accepting the event name and parameters in Firebase package.
    public func logEvent(_ event: LoggableEvent, parameters params: [String: Any]) {
        let parameters = mergeAdditionalParameters(params)
        analytics.logEvent(event.name, parameters: parameters)
    }
    
    /// Logs crashes accepting an error in Firebase package.
    public func logCrash(_ error: NSError) {
        crashLogger.record(error: error)
    }
    
    /// Granting analytics and crashlytics permissions in Firebase package.
    public func grantAnalyticsPermission() {
        analytics.setAnalyticsCollectionEnabled(true)
        crashLogger.setCrashlyticsCollectionEnabled(true)
    }
    
    /// Denying analytics and crashlytics permissions in Firebase package.
    public func denyAnalyticsPermission() {
        analytics.setAnalyticsCollectionEnabled(false)
        analytics.resetAnalyticsData()
        
        crashLogger.setCrashlyticsCollectionEnabled(false)
    }
}
