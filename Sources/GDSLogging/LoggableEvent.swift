/// LoggingEvent
///
/// A protocol for Types to hold a value for event logging.
public protocol LoggableEvent {
    var name: String { get }
}

extension LoggableEvent where Self: RawRepresentable,
                                Self.RawValue == String {
    
    /// Protocol method returning the string value from a Type's `name` property which conforms to this protocol.
    public var name: String {
        rawValue
    }
}
