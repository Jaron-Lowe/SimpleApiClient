import Foundation

extension URLResponse {
	func validateStatusCode() throws {
		guard let httpResponse = self as? HTTPURLResponse, (200..<300) ~= httpResponse.statusCode else {
			throw HttpError.invalidStatusCode
		}
	}
}
