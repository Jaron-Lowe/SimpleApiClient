import Foundation

/// Provides an object the ability to apply itself to a `URLRequest`
public protocol URLRequestApplying {
    func apply(to request: inout URLRequest)
}
