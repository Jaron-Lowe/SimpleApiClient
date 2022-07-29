import Foundation

/// Represents an http action method.
public enum HttpMethod {
    case get
    case post
    case put
    case patch
    case delete
    
    /// Allows for providing an uncommon method value.
    case custom(String)
    
    /// The output value of the action method.
    var value: String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        case .put:
            return "PUT"
        case .patch:
            return "PATCH"
        case .delete:
            return "DELETE"
        case .custom(let customValue):
            return customValue
        }
    }
}

extension HttpMethod: URLRequestApplying {
    /// Applies the `HttpMethod` to a request object.
    /// - Parameter request: A request for which to apply the method.
    public func apply(to request: inout URLRequest) {
        request.httpMethod = self.value
    }
}
