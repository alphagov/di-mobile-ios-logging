@testable import GDSLogging
import XCTest

final class LoggingScreenTests: XCTestCase {
    func testNameConformance() {
        XCTAssertEqual(MockAnalyticsScreen.drivingLicenceFrontInstructions.name,
                       "drivingLicenceFrontInstructions")
    }
}

enum MockAnalyticsScreen: String, LoggableScreen {
    case drivingLicenceFrontInstructions
}
