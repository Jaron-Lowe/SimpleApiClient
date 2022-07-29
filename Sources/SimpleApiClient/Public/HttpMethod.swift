import Foundation

public enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

extension HttpMethod: URLRequestApplying {
    func apply(to request: inout URLRequest) {
        request.httpMethod = self.rawValue
    }
}
