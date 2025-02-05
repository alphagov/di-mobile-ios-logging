import GDSAnalytics
import Logging

public typealias ScreenType = Logging.ScreenType & GDSAnalytics.ScreenType

extension AnalyticsService {
    public func logEvent(_ event: Event) {
        logEvent(event.name,
                 parameters: event.parameters)
    }
    
    public func trackScreen<Screen>(_ screen: Screen)
    where Screen: ScreenViewProtocol & LoggableScreenV2 {
        trackScreen(screen, parameters: screen.parameters)
    }
}

extension EventName: @retroactive LoggableEvent { }

extension ScreenView: @retroactive LoggableScreenV2
where Screen: Logging.ScreenType {
    public var name: String {
        title
    }
    
    public var type: Logging.ScreenType {
        self.screen
    }
}
