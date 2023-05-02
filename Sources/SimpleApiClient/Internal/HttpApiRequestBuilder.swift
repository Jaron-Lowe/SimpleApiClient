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
		guard let url = url(for: api) else {
			throw URLError(.badURL)
		}
		var request = URLRequest(url: url, timeoutInterval: api.timeoutInterval)
		api.method.apply(to: &request)
		api.headers?.apply(to: &request)
		if case .body(let body) = api.parameters {
			body.apply(to: &request)
		}
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

	private func url<Api: HttpApiRequest>(for api: Api) -> URL? {
		guard var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true) else {
			return nil
		}

		components.path = components.path + api.endpointPath

		if case .query(let items) = api.parameters {
			components.queryItems = items.map { key, value in
				return URLQueryItem(name: key, value: value)
			}
		}

		return components.url
	}
}
