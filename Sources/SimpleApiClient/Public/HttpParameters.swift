import Foundation

/// Represents parameters to apply to an `HttpApiRequest`
public enum HttpParameters {
    /// Represents a set of query string parameters.
    case query(params: [String: String])
    
    /// Represents request body parameters.
    case body(HttpBody)
}
