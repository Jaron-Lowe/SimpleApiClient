import Foundation

extension JSONDecoder {
    /// A decoder using the convertFromSnakeCase key decoding strategy.
	public static let fromSnakeCaseDecoder = {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		return decoder
	}()
}
