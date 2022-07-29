import Foundation

/// A concrete type used to wrap an abstract `Encodable` value.
struct WrappedEncodable: Encodable {
    /// The wrapped abstract `Encodable` value
    let wrappedValue: Encodable
    
    func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
}
