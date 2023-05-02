import Foundation

extension JSONDecoder {
	public static let fromSnakeCaseDecoder = {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		return decoder
	}()
}
