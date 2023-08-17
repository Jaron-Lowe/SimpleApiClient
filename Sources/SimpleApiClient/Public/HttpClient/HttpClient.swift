import Foundation

public typealias DecodableError = (Decodable & Error)

open class HttpClient {
    // MARK: Properties
    private let baseUrl: URL
	private let adapters: [HttpAdapter]
	let decoder: JSONDecoder
	let invalidStatusCodeType: DecodableError.Type?
	
	lazy var requestBuilder: HttpApiRequestBuilder = {
		return HttpApiRequestBuilder(baseUrl: baseUrl, adapters: adapters)
	}()
    
    // MARK: Init
	
	/// Initializes
	/// - Parameters:
	///   - baseUrl: The `URL` to prepend all to all requests.
	///   - adapters: An array of Adapters by which to modify all requests.
	///   - decoder: A custom `JSONDecoder` to utilize for all response decoding.
	///   - invalidStatusCodeType: A `Decodable` type to parse a response by if a non-valid status code is encountered.
	public init(baseUrl: URL, adapters: [HttpAdapter] = [], decoder: JSONDecoder = .fromSnakeCaseDecoder, invalidStatusCodeType: DecodableError.Type?) {
        self.baseUrl = baseUrl
		self.adapters = adapters
		self.decoder = decoder
		self.invalidStatusCodeType = invalidStatusCodeType
    }
}

extension HttpClient {
	/// Validates a `URLResponse` and decodes either a valid result or invalid error
	/// In the case of an invalid response, the error is thrown.
	static func validateAndDecodeResult<Response: Decodable>(response: (Data, URLResponse), responseType: Response.Type, invalidType: DecodableError.Type?, decoder: JSONDecoder) throws -> Response {
		let (responseData, response) = response
		guard response.isStatusCodeValid else {
			guard let invalidType else {
				throw URLError(.badServerResponse)
			}
			let error = try decoder.decode(invalidType, from: responseData)
			throw error
		}
		return try decoder.decode(responseType, from: responseData)
	}
}
