import Foundation

/// Represents an HTTP Request body.
public enum HttpBody {
    /// Represents a url encoded form body.
    case form(body: Encodable)
    
    /// Represents a json encoded body.
    case json(body: Encodable)
    
    /// The encodable data associated with the body.
    var body: Encodable {
        switch self {
        case .form(let body), .json(let body):
            return body
        }
    }
    
    /// The content type value associated with the body.
    var contentType: String {
        switch self {
        case .form:
            return "application/x-www-form-urlencoded charset=utf-8"
        case .json:
            return "application/json"
        }
    }
}

extension HttpBody: URLRequestApplying {
    /// Applies the `HttpBody` to a request object.
    /// - Parameter request: A request for which to apply the body.
    public func apply(to request: inout URLRequest) {
        let wrappedBody = WrappedEncodable(wrappedValue: body)
        let encoder = JSONEncoder()
        let data = try? encoder.encode(wrappedBody)
        request.httpBody = data
        
        request.addValue(self.contentType, forHTTPHeaderField: "Content-Type")
    }
}
