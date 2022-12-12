import Foundation
import Combine

extension HttpClient {
	public func send<Api: HttpApiRequest>(api: Api) -> AnyPublisher<AsyncResult<Api.ResponseType, Error>, Never> {
		do {
			let request = try requestBuilder.request(for: api)
			return send(request: request, for: Api.ResponseType.self)
				.mapToAsyncResult()
		} catch {
			return Just(AsyncResult.failure(error))
				.eraseToAnyPublisher()
		}
	}
	
	public func send<Api: HttpApiRequest, T>(api: Api, keyPath: KeyPath<Api.ResponseType, T>) -> AnyPublisher<AsyncResult<T, Error>, Never> {
		do {
			let request = try requestBuilder.request(for: api)
			return send(request: request, for: Api.ResponseType.self)
				.map { $0[keyPath: keyPath] }
				.mapToAsyncResult()
		} catch {
			return Just(AsyncResult.failure(error))
				.eraseToAnyPublisher()
		}
	}
}

private extension HttpClient {
	func send<Response: Decodable>(request: URLRequest, for type: Response.Type) -> AnyPublisher<Response, Error> {
		return URLSession.shared.dataTaskPublisher(for: request)
			.validateStatusCode()
			.map { $0.data }
			.decode(type: type, decoder: decoder)
			.eraseToAnyPublisher()
	}
}

// MARK: - Publisher
extension Publisher where Output == URLSession.DataTaskPublisher.Output {
	func validateStatusCode() -> AnyPublisher<Output, Error> {
		return self
			.tryMap {
				try $0.response.validateStatusCode()
				return $0
			}
			.eraseToAnyPublisher()
	}
}
