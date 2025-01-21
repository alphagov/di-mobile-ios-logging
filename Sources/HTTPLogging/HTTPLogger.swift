import Foundation
import GDSLogging
import Networking

/// HTTPLogger
///
/// A struct for sending HTTP requests to log user/journey specific insights for app metrics and performance.
public struct HTTPLogger: LoggingService {
    /// `NetworkClient` from the Networking package dependency to handle HTTP networking
    let networkClient: NetworkClient
    /// `URL` address for sending HTTP requests
    let loggingURL: URL
    /// sessionID for user/journey identication
    let sessionID: String
    /// callback to handle possible errors resulting from `NetworkClient`'s `makeRequest` method
    let handleError: ((Error) -> Void)?
    
    /// Sends HTTP POST request to designated URL, handling errors received back from `NetworkClient`'s `makeRequest` method
    public func logEvent(_ event: LoggableEvent,
                         parameters: [String: Any]) {
        let httpLogRequest = HTTPLogRequest(authSessionID: sessionID, event: event)
        guard let jsonData = try? JSONEncoder().encode(httpLogRequest) else {
            assertionFailure("Failed to decode object")
            return
        }
        
        Task {
            var request = URLRequest(url: loggingURL)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            
            do {
                _ = try await networkClient.makeRequest(request)
            } catch {
                handleError?(error)
            }
        }
    }
    
    /// Initialiser for class with default methods for `networkClient` and `handleError` parameters
    public init(sessionID: String,
                url: URL,
                networkClient: NetworkClient = NetworkClient(),
                handleError: ((Error) -> Void)? = nil) {
        loggingURL = url
        self.sessionID = sessionID
        self.networkClient = networkClient
        self.handleError = handleError
    }
}
