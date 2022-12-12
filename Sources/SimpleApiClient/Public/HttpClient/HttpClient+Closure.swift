import Foundation

extension HttpClient {
	public func send<Api: HttpApiRequest>(api: Api, completion: ((Result<Api.ResponseType, Error>) -> ())?) {
		do {
			let request = try requestBuilder.request(for: api)
			send(request: request, for: Api.ResponseType.self) { result in
				completion?(result)
			}
		} catch {
			completion?(.failure(error))
		}
	}
	
	public func send<Api: HttpApiRequest, T>(api: Api, keyPath: KeyPath<Api.ResponseType, T>, completion: ((Result<T, Error>) -> ())?) {
		
		do {
			let request = try requestBuilder.request(for: api)
			send(request: request, for: Api.ResponseType.self) { result in
				switch result {
				case .success(let value):
					completion?(.success(value[keyPath: keyPath]))
				case .failure(let error):
					completion?(.failure(error))
				}
			}
		} catch {
			completion?(.failure(error))
		}
	}
}

private extension HttpClient {
	func send<Response: Decodable>(request: URLRequest, for type: Response.Type, completion: ((Result<Response, Error>) -> ())?) {
		
		URLSession.shared.dataTask(with: request) { [decoder = self.decoder] data, response, error in
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
			
			guard let data = data, let decodedValue = try? decoder.decode(type, from: data) else {
				completion?(.failure(HttpError.invalidResponseData))
				return
			}
			
			completion?(.success(decodedValue))
		}
	}
}
