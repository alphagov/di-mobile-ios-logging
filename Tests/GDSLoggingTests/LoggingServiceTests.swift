@testable import GDSLogging
import XCTest

final class LoggingServiceTests: XCTestCase {
    func testAnalyticsService() {
        let service = MockLoggingService()
        service.logEvent(MockAnalyticsEvent.completedIDCheck, parameters: [:])
        XCTAssertEqual(service.eventsLogged.count, 1)
        
        service.trackScreen(MockAnalyticsScreen.drivingLicenceFrontInstructions)
        XCTAssertEqual(service.screensVisited.count, 1)
        
        service.logEvent(MockAnalyticsEvent.completedIDCheck)
        XCTAssertEqual(service.eventsLogged.count, 2)
        
        service.trackScreen(MockAnalyticsScreen.drivingLicenceFrontInstructions)
        XCTAssertEqual(service.screensVisited.count, 2)
    }
    
    enum TestScreen: String, LoggableScreen {
        case welcome = "WELCOME_SCREEN"
    }
    
    func testTrackScreen() {
        let service = MockLoggingService()
        service.trackScreen(TestScreen.welcome, parameters: [:])
        
        XCTAssertEqual(
            service.screensVisited,
            [
                MockScreen(name: "WELCOME_SCREEN", class: "WELCOME_SCREEN")
            ]
        )
    }
    
    func testTrackScreenV2() {
        struct TestScreenV2: LoggableScreenV2 {
            let name: String = "Welcome to GOV.UK One Login"
            let type: ScreenType = TestScreen.welcome
        }
        
        let service = MockLoggingService()
        service.trackScreen(TestScreenV2(), parameters: [:])
        
        XCTAssertEqual(
            service.screensVisited,
            [
                MockScreen(name: "Welcome to GOV.UK One Login", class: "WELCOME_SCREEN")
            ]
        )
    }
}
