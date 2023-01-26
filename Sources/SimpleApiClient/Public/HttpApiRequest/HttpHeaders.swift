import Foundation

/// A dictionary of Http headers.
public typealias HttpHeaders = [String: String]
extension HttpHeaders: URLRequestApplying {
	/// Applies the `HttpHeaders` to a request object.
	/// - Parameter request: A request for which to apply the headers.
	public func apply(to request: inout URLRequest) {
		for (key, value) in self {
			request.setValue(value, forHTTPHeaderField: key)
		}
	}
}
