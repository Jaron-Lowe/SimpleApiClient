import Foundation
import Combine

extension HttpClient {
	/// Asynchronously returns the response of the sent api without the ability to cancel.
	/// - Parameter api: The `HttpApiRequest` to send.
	/// - Returns: The response of the sent api.
	public func sendAsync<Api: HttpApiRequest>(api: Api) async throws -> Api.ResponseType {
		return try await sendTask(api: api).value
	}
	
	/// Returns a cancellable task that can be awaited to retireve the api response.
	/// - Parameter api: The `HttpApiRequest` to send.
	/// - Returns: A task of work for the sending of the api.
	public func sendTask<Api: HttpApiRequest>(api: Api) -> Task<Api.ResponseType, Error> {
		return Task {
			let request = try await self.requestBuilder.requestTask(for: api).value
			return try await self.send(request: request, for: Api.ResponseType.self).value
		}
	}
}

private extension HttpClient {
	func send<Response: Decodable>(request: URLRequest, for type: Response.Type) -> Task<Response, Error> {
		return Task {
			try Task.checkCancellation()
			let response = try await URLSession.shared.data(for: request)
			return try HttpClient.validateAndDecodeResult(
				response: response,
				responseType: type,
				invalidType: invalidStatusCodeType,
				decoder: decoder
			)
		}
	}
}
