@testable import HTTPLogging
import GDSLogging
import MockNetworking
@testable import Networking
import XCTest

enum MockEvent: String, LoggableEvent {
    case testEvent
}

final class HTTPLoggingTests: XCTestCase {
    private var sessionID: String!
    private var sut: HTTPLogger!
    private var mockRequest: String!
    private var client: NetworkClient!
    private var configuration: URLSessionConfiguration!
    
    override func setUp() {
        super.setUp()
        configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        client = NetworkClient(configuration: configuration)
        
        sessionID = UUID().uuidString
        
        sut = .init(sessionID: sessionID,
                    url: URL(string: "https://example.com/dev")!,
                    networkClient: client)
        
        mockRequest =
        """
         {
          "sessionId": "\(sessionID!)",
          "eventName": "\(MockEvent.testEvent.rawValue)"
         }
        """
    }
    
    override func tearDown() {
        sessionID = nil
        sut = nil
        mockRequest = nil
        client = nil
        MockURLProtocol.clear()
        configuration = nil
        super.tearDown()
    }
}

extension HTTPLoggingTests {
    func test_successfulTXMAEventLog() throws {
        // GIVEN network client returns 200
        MockURLProtocol.handler = {
            (Data(), HTTPURLResponse(statusCode: 200))
        }
        
        // WHEN an event is logged
        sut.logEvent(MockEvent.testEvent)
        
        wait(for: [
            XCTNSPredicateExpectation(predicate: .init(block: { _, _ in
                MockURLProtocol.requests.count == 1
            }), object: nil)
        ], timeout: 3)
        
        // THEN the request succeeds
        let request = try XCTUnwrap(MockURLProtocol.requests.first)
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url?.scheme, "https")
        XCTAssertEqual(request.url?.host, "example.com")
        XCTAssertEqual(request.url?.path, "/dev")

        let httpData = try XCTUnwrap(request.httpBodyData())
        let decoder = JSONDecoder()
        let httpBody = try decoder.decode([String: String].self, from: httpData)

        let ID = try XCTUnwrap(httpBody["sessionId"])
        XCTAssertEqual(sessionID, ID)
        
        let eventName = try XCTUnwrap(httpBody["eventName"])
        XCTAssertEqual(MockEvent.testEvent.rawValue, eventName)
    }
    
    func test_TXMAEventLog_throwsError() throws {
        // GIVEN network client returns 401 error
        MockURLProtocol.handler = {
            (Data(), HTTPURLResponse(statusCode: 401))
        }
        
        // WHEN a TXMA event is logged
        sut.logEvent(MockEvent.testEvent)
        wait(for: [
            XCTNSPredicateExpectation(predicate: .init(block: { _, _ in
                MockURLProtocol.requests.count == 1
            }), object: nil)
        ], timeout: 3)
        // XCTAssertEqual(error.errorCode, 401)
        
        XCTAssertEqual(MockURLProtocol.requests.count, 1)
        
        let request = try XCTUnwrap(MockURLProtocol.requests.first)
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url?.scheme, "https")
        XCTAssertEqual(request.url?.host, "example.com")
        XCTAssertEqual(request.url?.path, "/dev")

        let httpData = try XCTUnwrap(request.httpBodyData())
        let decoder = JSONDecoder()
        let httpBody = try decoder.decode([String: String].self, from: httpData)

        let ID = try XCTUnwrap(httpBody["sessionId"])
        XCTAssertEqual(sessionID, ID)
        
        let eventName = try XCTUnwrap(httpBody["eventName"])
        XCTAssertEqual(MockEvent.testEvent.rawValue, eventName)
    }
}


private struct HTTPLogRequest: Codable {
    let sessionID: String
    let eventName: String
    
    init(authSessionID: String, event: LoggableEvent) {
        self.sessionID = authSessionID
        self.eventName = event.name
    }
    
    enum CodingKeys: String, CodingKey {
        case sessionID = "sessionId"
        case eventName
    }
}
