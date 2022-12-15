import Foundation

extension JSONDecoder {
	static let fromSnakeCaseDecoder = {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		return decoder
	}()
}
