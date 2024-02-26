@testable import GAnalytics
import Logging
import XCTest

final class GAnalyticsTests: XCTestCase {
    private var sut: GAnalytics!
    
    private var app: MockApp.Type!
    private var analyticsLogger: MockAnalyticsLogger.Type!
    private var crashLogger: MockCrashLogger!
    private var preferenceStore: AnalyticsPreferenceStore!
    
    override func setUp() {
        super.setUp()
        
        app = MockApp.self
        analyticsLogger = MockAnalyticsLogger.self
        crashLogger = MockCrashLogger()
        preferenceStore = MockPreferenceStore()
        
        sut = GAnalytics(app: app,
                         analytics: analyticsLogger,
                         crashLogger: crashLogger, 
                         preferenceStore: preferenceStore)
    }
    
    override func tearDown() {
        sut = nil
        analyticsLogger.reset()
        analyticsLogger = nil
        crashLogger = nil
        preferenceStore = nil
        super.tearDown()
    }
}

// MARK: - Setup Tests
extension GAnalyticsTests {
    func testConfiguration() {
        sut.configure()
        
        XCTAssertTrue(app.calledConfigure)
        NotificationCenter.default.post(Notification(name: UserDefaults.didChangeNotification))
    }
}

// MARK: - Logging Tests
extension GAnalyticsTests {
    enum TestScreen: String, LoggableScreen {
        case welcome = "WELCOME_SCREEN"
    }
    
    func testTrackScreen() {
        sut.trackScreen(TestScreen.welcome,
                        parameters: ["additional_parameter": "testing"])
        
        XCTAssertEqual(
            analyticsLogger.events,
            [.init(name: "screen_view", parameters: [
                "screen_class": "WELCOME_SCREEN",
                "screen_name": "WELCOME_SCREEN",
                "additional_parameter": "testing"
            ])]
        )
    }
    
    func testTrackScreenAdditionalParameters() {
        sut.additionalParameters = [
            "journey": "id_verification"
        ]
        
        sut.trackScreen(TestScreen.welcome,
                        parameters: ["additional_parameter": "testing"])
        
        XCTAssertEqual(
            analyticsLogger.events,
            [.init(name: "screen_view", parameters: [
                "screen_class": "WELCOME_SCREEN",
                "screen_name": "WELCOME_SCREEN",
                "additional_parameter": "testing",
                "journey": "id_verification"
            ])]
        )
    }
    
    func testTrackScreenV2() {
        struct TestScreenV2: LoggableScreenV2 {
            let name: String = "Welcome to GOV.UK One Login"
            let type: ScreenType = TestScreen.welcome
        }
        
        sut.trackScreen(TestScreenV2(),
                        parameters: ["additional_parameter": "testing"])
        
        XCTAssertEqual(
            analyticsLogger.events,
            [.init(name: "screen_view", parameters: [
                "screen_class": "WELCOME_SCREEN",
                "screen_name": "Welcome to GOV.UK One Login",
                "additional_parameter": "testing"
            ])]
        )
    }
    
    func testTrackEvent() {
        enum MyAppEvents: String, LoggableEvent {
            case buttonPress
        }
        
        sut.logEvent(MyAppEvents.buttonPress)
        
        XCTAssertEqual(
            analyticsLogger.events,
            [.init(name: "buttonPress", parameters: [:])]
        )
    }
    
    func testLogCrash() {
        enum MyAppError: Error, Equatable {
            case unknownFailure
        }
        
        sut.logCrash(MyAppError.unknownFailure)
        
        XCTAssertEqual(crashLogger.errors.count, 1)
        XCTAssertEqual(
            crashLogger.errors.compactMap { $0 as? MyAppError },
            [MyAppError.unknownFailure]
        )
    }
    
    func testGrantAnalyticsPermission() {
        sut.grantAnalyticsPermission()
        
        XCTAssertEqual(analyticsLogger.isAnalyticsCollectionEnabled, true)
        XCTAssertEqual(crashLogger.isCollectionEnabled, true)
    }
    
    func testDenyAnalyticsPermission() {
        sut.denyAnalyticsPermission()
        
        XCTAssertTrue(analyticsLogger.didResetAnalyticsData)
        
        XCTAssertEqual(analyticsLogger.isAnalyticsCollectionEnabled, false)
        XCTAssertEqual(crashLogger.isCollectionEnabled, false)
    }
}
