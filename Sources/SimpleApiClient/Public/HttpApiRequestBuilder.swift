import Foundation

final class HttpApiRequestBuilder {
	// MARK: Properties
	private let baseUrl: URL
	
	// MARK: Init
	init(baseUrl: URL) {
		self.baseUrl = baseUrl
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
