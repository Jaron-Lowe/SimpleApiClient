import Foundation

extension HttpClient {
	public func send<Api: HttpApiRequest>(api: Api) async throws -> Api.ResponseType {
		let request = try requestBuilder.request(for: api)
		return try await send(request: request, for: Api.ResponseType.self)
	}
	
	public func send<Api: HttpApiRequest, T>(api: Api, keyPath: KeyPath<Api.ResponseType, T>) async throws -> T {
		let request = try requestBuilder.request(for: api)
		let response = try await send(request: request, for: Api.ResponseType.self)
		return response[keyPath: keyPath]
	}
}

private extension HttpClient {
	func send<Response: Decodable>(request: URLRequest, for type: Response.Type) async throws -> Response {
		let (responseData, response) = try await URLSession.shared.data(for: request)
		try response.validateStatusCode()
		return try decoder.decode(type, from: responseData)
	}
}
