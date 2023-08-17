import Foundation

extension HttpClient {
	/// Sends an api request and returns with its result in a completion handler.
	/// - Parameters:
	///   - api: The api to send.
	///   - completion: The completion handler containing the result of the sent api.
	/// - Returns: The `URLSessionDataTask` used to send the api that can be used for cancelling.
	public func send<Api: HttpApiRequest>(api: Api, completion: ((Result<Api.ResponseType, Error>) -> ())?) {
		requestBuilder.request(for: api) { result in
			switch result {
			case .success(let request):
				self.send(request: request, for: Api.ResponseType.self) { result in
					completion?(result)
				}
			case .failure(let error):
				completion?(.failure(error))
			}
		}
	}
}

private extension HttpClient {
	@discardableResult
	func send<Response: Decodable>(request: URLRequest, for type: Response.Type, completion: ((Result<Response, Error>) -> ())?) -> URLSessionDataTask? {
		let task = URLSession.shared.dataTask(with: request) { [decoder = self.decoder, invalidType = self.invalidStatusCodeType] data, response, error in
			if let error {
				completion?(.failure(error))
				return
			}
			
			guard let data, let response else {
				completion?(.failure(URLError(.badServerResponse)))
				return
			}
			
			do {
				let result = try HttpClient.validateAndDecodeResult(
					response: (data, response),
					responseType: type,
					invalidType: invalidType,
					decoder: decoder
				)
				completion?(.success(result))
			}
			catch {
				completion?(.failure(URLError(.badServerResponse)))
			}
		}
		task.resume()
		return task
	}
}
