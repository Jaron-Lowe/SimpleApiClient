import Foundation

open class HttpClient {
    // MARK: Properties
    private let baseUrl: URL
	private let adapters: [HttpAdapter]
	
	let decoder: JSONDecoder
	lazy var requestBuilder: HttpApiRequestBuilder = {
		return HttpApiRequestBuilder(baseUrl: baseUrl, adapters: adapters)
	}()
    
    // MARK: Init
	public init(baseUrl: URL, adapters: [HttpAdapter] = [], decoder: JSONDecoder = .fromSnakeCaseDecoder) {
        self.baseUrl = baseUrl
		self.adapters = adapters
		self.decoder = decoder
    }
}
