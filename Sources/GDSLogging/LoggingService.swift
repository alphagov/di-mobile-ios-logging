import Foundation

/// LogginService
///
/// A protocol for Types to log events to a HTTP analytics service.
public protocol LoggingService {
    func logEvent(_ event: LoggableEvent, parameters: [String: Any])
}

extension LoggingService {
    /// Protocol method for logging an analytics event, calling the conforming type's method for adding event logging parameters.
    public func logEvent(_ event: LoggableEvent) {
        logEvent(event, parameters: [:])
    }
}
