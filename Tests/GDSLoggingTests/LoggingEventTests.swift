@testable import GDSLogging
import XCTest

final class LoggingEventTests: XCTestCase {
    func testNameConformance() {
        XCTAssertEqual(MockAnalyticsEvent.completedIDCheck.name,
                       "completedIDCheck")
    }
}

enum MockAnalyticsEvent: String, LoggableEvent {
    case completedIDCheck
}
