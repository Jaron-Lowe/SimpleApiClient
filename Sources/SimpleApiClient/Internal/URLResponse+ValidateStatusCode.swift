import Foundation

extension URLResponse {
	var isStatusCodeValid: Bool {
		guard let httpResponse = self as? HTTPURLResponse, (200..<300) ~= httpResponse.statusCode else { return false }
		return true
	}
}
