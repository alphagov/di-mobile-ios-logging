@testable import GDSLogging
import XCTest

final class UserDefaultsPreferenceStoreTests: XCTestCase {
    
    private var sut: UserDefaultsPreferenceStore!
    private var defaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        defaults = UserDefaults()
        sut = UserDefaultsPreferenceStore(defaults: defaults)
    }
    
    override func tearDown() {
        super.tearDown()
        
        defaults.removeObject(forKey: "hasAskedForAnalyticsPermissions")
        defaults.removeObject(forKey: "hasAcceptedAnalytics")
        defaults = nil
    }
}

// MARK: - Preference change
extension UserDefaultsPreferenceStoreTests {
    func testFetchValue() {
        XCTAssertNil(
            sut.hasAcceptedAnalytics
        )
        
        defaults.set(true, forKey: "hasAskedForAnalyticsPermissions")
        defaults.set(true, forKey: "hasAcceptedAnalytics")
        
        XCTAssertEqual(sut.hasAcceptedAnalytics, true)
        
        defaults.set(false, forKey: "hasAcceptedAnalytics")
        XCTAssertEqual(sut.hasAcceptedAnalytics, false)
    }
    
    func testClearAnalyticsPreference() {
        sut.hasAcceptedAnalytics = nil
        
        XCTAssertFalse(defaults.bool(forKey: "hasAskedForAnalyticsPermissions"))
        XCTAssertFalse(defaults.bool(forKey: "hasAcceptedAnalytics"))
    }
    
    func testAcceptAnalytics() {
        sut.hasAcceptedAnalytics = true
        
        XCTAssertTrue(defaults.bool(forKey: "hasAskedForAnalyticsPermissions"))
        XCTAssertTrue(defaults.bool(forKey: "hasAcceptedAnalytics"))
    }
    
    func testDenyAnalytics() {
        sut.hasAcceptedAnalytics = false
        
        XCTAssertTrue(defaults.bool(forKey: "hasAskedForAnalyticsPermissions"))
        XCTAssertFalse(defaults.bool(forKey: "hasAcceptedAnalytics"))
    }
}

// MARK: - Subscribe to stream
extension UserDefaultsPreferenceStoreTests {
    func testSubscribeToExternalUpdates() {
        let subscriptionExpectation = expectation(description: "Wait for test to subscribe")
        
        let resultExpectation = expectation(description: "Wait for result to be sent from stream")
        resultExpectation.assertForOverFulfill = false
        
        Task {
            subscriptionExpectation.fulfill()
            
            for await _ in sut.stream() {
                resultExpectation.fulfill()
            }
        }
        
        wait(for: [subscriptionExpectation], timeout: 3)
        
        defaults.set(true, forKey: "hasAskedForAnalyticsPermissions")
        defaults.set(true, forKey: "hasAcceptedAnalytics")
        
        wait(for: [resultExpectation], timeout: 3)
    }
}
