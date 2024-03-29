#if !((os(iOS) && (arch(i386) || arch(arm))) || os(Windows) || os(Linux))

import Foundation
import Combine

extension HttpClient {
	/// Returns a publisher for sending an api.
	/// - Parameter api: The api to be sent.
	public func sendPublisher<Api: HttpApiRequest>(api: Api) -> AnyPublisher<AsyncResult<Api.ResponseType, Error>, Never> {
		return requestBuilder.requestPublisher(for: api)
			.flatMap { self.sendPublisher(request: $0, for: Api.ResponseType.self) }
			.mapToAsyncResult()
	}
}

private extension HttpClient {
	func sendPublisher<Response: Decodable>(request: URLRequest, for type: Response.Type) -> AnyPublisher<Response, Error> {
		return URLSession.shared.dataTaskPublisher(for: request)
			.validateAndDecodeResult(responseType: type, invalidType: invalidStatusCodeType, decoder: decoder)
			.eraseToAnyPublisher()
	}
}

/// A value that represents an asynchronous result, including a result that is still in progress.
public enum AsyncResult<Success, Failure> {
	case inProgress
	case success(Success)
	case failure(Failure)
	
	/// Returns the value associated with a success result.
	public var successValue: Success? {
		guard case .success(let value) = self else {
			return nil
		}
		return value
	}
	
	/// Returns the value associated with a failure result.
	public var failureValue: Failure? {
		guard case .failure(let value) = self else {
			return nil
		}
		return value
	}
	
	/// Returns whether the result is still in progress.
	public var isInProgress: Bool {
		if case .inProgress = self {
			return true
		}
		return false
	}
	
	/// Returns whether the result is a success.
	public var isSuccess: Bool {
		return (successValue != nil)
	}
	
	/// Returns whether the result is a faillure.
	public var isFailure: Bool {
		return (failureValue != nil)
	}
}

extension Publisher {
	/// Transforms a publisher with concrete Output and Failure types to a new publisher that wraps Output and Failure into an AsyncResult.
	/// The new publisher is prepended with an AsyncResult.InProgress.
	/// - Returns: A type-erased publisher of type `<AsyncResult<Output, Failure>, Never>`.
	public func mapToAsyncResult() -> AnyPublisher<AsyncResult<Output, Failure>, Never> {
		return self
			.map { AsyncResult.success($0) }
			.catch { Just(AsyncResult.failure($0)) }
			.prepend(AsyncResult.inProgress)
			.eraseToAnyPublisher()
	}
}

// MARK: - Publisher
extension Publisher where Output == URLSession.DataTaskPublisher.Output {
	func validateAndDecodeResult<Response: Decodable>(responseType: Response.Type, invalidType: DecodableError.Type?, decoder: JSONDecoder) -> AnyPublisher<Response, Error> {
		return self
			.tryMap {
				try HttpClient.validateAndDecodeResult(
					response: $0,
					responseType: responseType,
					invalidType: invalidType,
					decoder: decoder
				)
			}
			.eraseToAnyPublisher()
	}
}

#endif
