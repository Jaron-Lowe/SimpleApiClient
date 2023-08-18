import Foundation
import Combine

final class HttpApiRequestBuilder {
	// MARK: Properties
	private let baseUrl: URL
	private let adapters: [HttpAdapter]
	
	// MARK: Init
	init(baseUrl: URL, adapters: [HttpAdapter]) {
		self.baseUrl = baseUrl
		self.adapters = adapters
	}
	
	func request<Api: HttpApiRequest>(for api: Api) throws -> URLRequest {
		guard let url = URL(string: api.endpointPath, relativeTo: baseUrl) else {
			throw URLError(.badURL)
		}
		var request = URLRequest(url: url, timeoutInterval: api.timeoutInterval)
		api.method.apply(to: &request)
		api.headers?.apply(to: &request)
		api.parameters?.apply(to: &request)
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
		return Deferred {
			Future {
				try await self.requestTask(for: api).value
			}
		}.eraseToAnyPublisher()
	}
	
	func requestTask<Api: HttpApiRequest>(for api: Api) throws -> Task<URLRequest, Error> {
		return adaptedRequest(try request(for: api))
	}
	
	func adaptedRequest(_ request: URLRequest) -> Task<URLRequest, Error> {
		return Task {
			var adaptableRequest = request
			for adapter in adapters {
				adaptableRequest = try await adapter.adapt(request: adaptableRequest).value
			}
			return adaptableRequest
		}
	}
}
