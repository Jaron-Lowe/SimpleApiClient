import Foundation

public enum HttpParameters {
    case query(params: [String: String])
    case body(HttpBody)
}
