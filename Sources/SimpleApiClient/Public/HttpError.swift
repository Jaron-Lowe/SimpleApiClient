import Foundation

public enum HttpError: Error {
    /// The provided api is malformed. A request was not able to be generated.
    case malformedApi
}
