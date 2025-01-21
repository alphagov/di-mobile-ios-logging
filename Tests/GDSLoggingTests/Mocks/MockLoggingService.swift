import Foundation
import GDSLogging

struct MockScreen: Equatable {
    let name: String
    let `class`: String
}

final class MockLoggingService: AnalyticsService {
    var additionalParameters: [String: Any] = [:]
    
    var screensVisited: [MockScreen] = []
    var screenParamsLogged: [String: Any] = [:]
    var eventsLogged: [LoggableEvent] = []
    
    func logCrash(_ crash: NSError) { }
    func grantAnalyticsPermission() { }
    func denyAnalyticsPermission() { }
    
    func trackScreen(_ screen: LoggableScreen,
                     parameters: [String: Any]) {
        screensVisited.append(MockScreen(name: screen.name, class: screen.name))
        screenParamsLogged = parameters
    }
    
    func trackScreen(_ screen: LoggableScreenV2,
                     parameters: [String: Any]) {
        screensVisited.append(
            MockScreen(name: screen.name, class: screen.type.name)
        )
        screenParamsLogged = parameters
    }
    
    func logEvent(_ event: LoggableEvent,
                  parameters: [String: Any]) {
        eventsLogged.append(event)
    }
}
