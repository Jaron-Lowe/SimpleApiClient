import Foundation

/// Represents parameters to apply to an `HttpApiRequest`
public enum HttpParameters {
    /// Represents a set of query string parameters.
    case query(params: [String: String])
    
    /// Represents request body parameters.
    case body(HttpBody)
}

extension HttpParameters: URLRequestApplying {
	/// Applies the `HttpParameters` to a request object.
	/// - Parameter request: A request for which to apply the parameters.
	public func apply(to request: inout URLRequest) {
		switch self {
		case .query(let params):
			guard let url = request.url, var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
			components.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
			request.url = components.url
			
		case .body(let body):
			body.apply(to: &request)
		}
	}
}
