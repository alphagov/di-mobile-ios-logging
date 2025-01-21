/// ScreenType
///
/// A protocol for types to hold a value for screen tracking.
public protocol ScreenType {
    var name: String { get }
}

extension ScreenType where Self: RawRepresentable,
                                Self.RawValue == String {
    
    /// Protocol method returning the string value from a Type's `name` property which conforms to this protocol.
    public var name: String {
        rawValue
    }
}
