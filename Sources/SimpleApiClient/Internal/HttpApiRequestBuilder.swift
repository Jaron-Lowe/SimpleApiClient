import Foundation
import Combine

final class HttpApiRequestBuilder {
	// MARK: Properties
    
	private let baseUrl: URL
    private let session: URLSession
	private let transformers: [HttpRequestTransformer]
	
	// MARK: Init
    
    init(baseUrl: URL, session: URLSession, transformers: [HttpRequestTransformer]) {
		self.baseUrl = baseUrl
        self.session = session
		self.transformers = transformers
	}
	
	func request<Api: HttpApiRequest>(for api: Api) throws -> URLRequest {
		guard let url = URL(string: api.endpointPath, relativeTo: baseUrl) else {
			throw URLError(.badURL)
		}
		var request = URLRequest(url: url, timeoutInterval: api.timeoutInterval)
		api.method.apply(to: &request)
		api.headers?.apply(to: &request)
        api.queryItems?.apply(to: &request)
        api.body?.apply(to: &request)
		return request
	}
	
	func request<Api: HttpApiRequest>(for api: Api, completion: @escaping (Result<URLRequest, Error>) -> ()) {
		Task {
			do {
				let request = try await requestTask(for: api).value
				completion(.success(request))
			}
			catch {
				completion(.failure(error))
			}
		}
	}
	
	func requestPublisher<Api: HttpApiRequest>(for api: Api) -> AnyPublisher<URLRequest, Error> {
        Deferred {
			Future {
				try await self.requestTask(for: api).value
			}
		}.eraseToAnyPublisher()
	}
	
	func requestTask<Api: HttpApiRequest>(for api: Api) throws -> Task<URLRequest, Error> {
        adaptedRequest(try request(for: api))
	}
	
	func adaptedRequest(_ request: URLRequest) -> Task<URLRequest, Error> {
        Task {
			var transformableRequest = request
            for transformer in transformers {
                transformableRequest = try await transformer.transform(request: transformableRequest, session: session).value
			}
			return transformableRequest
		}
	}
}
