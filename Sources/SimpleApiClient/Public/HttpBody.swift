import Foundation

public enum HttpBody {
    case form(body: Encodable)
    case json(body: Encodable)
    
    var contentType: String {
        switch self {
        case .form:
            return "application/x-www-form-urlencoded"
        case .json:
            return "application/json"
        }
    }
}

extension HttpBody: URLRequestApplying {
    public func apply(to request: inout URLRequest) {
        switch self {
        case .form(let body), .json(let body):
            let wrappedBody = WrappedEncodable(wrappedValue: body)
            let encoder = JSONEncoder()
            let data = try? encoder.encode(wrappedBody)
            request.httpBody = data
        }
    }
}
