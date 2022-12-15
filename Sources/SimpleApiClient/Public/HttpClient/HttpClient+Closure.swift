import Foundation

extension HttpClient {
	/// Sends an api request and returns with its result in a completion handler.
	/// - Parameters:
	///   - api: The api to send.
	///   - completion: The completion handler containing the result of the sent api.
	/// - Returns: The `URLSessionDataTask` used to send the api that can be used for cancelling.
	public func send<Api: HttpApiRequest>(api: Api, completion: ((Result<Api.ResponseType, Error>) -> ())?) -> URLSessionDataTask? {
		do {
			let request = try requestBuilder.request(for: api)
			return send(request: request, for: Api.ResponseType.self) { result in
				completion?(result)
			}
		} catch {
			completion?(.failure(error))
			return nil
		}
	}
}

private extension HttpClient {
	func send<Response: Decodable>(request: URLRequest, for type: Response.Type, completion: ((Result<Response, Error>) -> ())?) -> URLSessionDataTask? {
		let task = URLSession.shared.dataTask(with: request) { [decoder = self.decoder] data, response, error in
			if let error = error {
				completion?(.failure(error))
				return
			}
			
			do {
				try response?.validateStatusCode()
			} catch {
				completion?(.failure(error))
				return
			}
			
			guard let data = data else {
				completion?(.failure(URLError(.badServerResponse)))
				return
			}
			
			guard let decodedValue = try? decoder.decode(type, from: data) else {
				completion?(.failure(URLError(.cannotParseResponse)))
				return
			}
			
			completion?(.success(decodedValue))
		}
		task.resume()
		return task
	}
}
