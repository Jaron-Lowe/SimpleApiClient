import Foundation

public typealias HttpHeaders = [String: String]
extension HttpHeaders: URLRequestApplying {
    public func apply(to request: inout URLRequest) {
        for (key, value) in self {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
}
