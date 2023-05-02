import Foundation

// MARK: - Adapting
public protocol HttpAdapter {
	func adapt(request: URLRequest) -> Task<URLRequest, Error>
}

// MARK: - Retrying
// TODO: Implement Retrying capabilities.
//public enum RetryBehavior {
//	case retry
//	case doNotRetry
//	case doNotRetryWithError(Error)
//}
//
//public protocol HttpRetrier {
//	func retry(request: URLRequest, for client: HttpClient, with error: Error) async -> RetryBehavior
//}
