import Foundation

public enum HttpBody {
    case form(body: Encodable)
    case json(body: Encodable)
    
    var body: Encodable {
        switch self {
        case .form(let body), .json(let body):
            return body
        }
    }
    
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
        let wrappedBody = WrappedEncodable(wrappedValue: body)
        let encoder = JSONEncoder()
        let data = try? encoder.encode(wrappedBody)
        request.httpBody = data
        
        request.addValue(self.contentType, forHTTPHeaderField: "Content-Type")
    }
}
