import Foundation

/// A dictionary of Http headers.
public typealias HttpHeaders = [String: String]

extension HttpHeaders {
	 func apply(to request: inout URLRequest) {
		for (key, value) in self {
			request.setValue(value, forHTTPHeaderField: key)
		}
	}
}
