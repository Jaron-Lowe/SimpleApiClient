import Foundation

open class HttpClient {
    // MARK: Properties
    private let baseUrl: URL
	let decoder: JSONDecoder
	lazy var requestBuilder: HttpApiRequestBuilder = {
		return HttpApiRequestBuilder(baseUrl: baseUrl)
	}()
    
    // MARK: Init
	public init(baseUrl: URL, decoder: JSONDecoder? = nil) {
        self.baseUrl = baseUrl
        if let decoder = decoder { self.decoder = decoder }
		else { self.decoder = .fromSnakeCaseDecoder }
    }
}
