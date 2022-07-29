import Foundation

public enum HttpError: Error {
    /// The provided api is malformed. A request was not able to be generated.
    case malformedApi
    
    /// The provided api' response returned an invalid status code.
    case invalidStatusCode
}
