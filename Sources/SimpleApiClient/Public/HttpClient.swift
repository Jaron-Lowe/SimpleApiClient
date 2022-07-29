import Foundation
import Combine

open class HttpClient {
    // MARK: Properties
    private let baseUrl: URL
    private let timeoutInterval: TimeInterval
    private let decoder: JSONDecoder
    
    // MARK: Init
    public init(baseUrl: URL, timeoutInterval: TimeInterval = 30.0, decoder: JSONDecoder? = nil) {
        self.baseUrl = baseUrl
        self.timeoutInterval = timeoutInterval
        if let decoder = decoder {
            self.decoder = decoder
        } else {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            self.decoder = decoder
        }
    }
    
    // MARK: Actions Methods
    public func send<Api: HttpApiRequest>(api: Api) -> AnyPublisher<AsyncResult<Api.ResponseType, Error>, Never> {
        guard let request = request(for: api) else {
            return Just(AsyncResult.failure(HttpError.malformedApi))
                .eraseToAnyPublisher()
        }
        return send(request: request, for: Api.ResponseType.self)
            .mapToAsyncResult()
    }
    
    public func send<Api: HttpApiRequest, T>(api: Api, keyPath: KeyPath<Api.ResponseType, T>) -> AnyPublisher<AsyncResult<T, Error>, Never> {
        guard let request = request(for: api) else {
            return Just(AsyncResult.failure(HttpError.malformedApi))
                .eraseToAnyPublisher()
        }
        return send(request: request, for: Api.ResponseType.self)
            .map { $0[keyPath: keyPath] }
            .mapToAsyncResult()
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

    func request<Api: HttpApiRequest>(for api: Api) -> URLRequest? {
        guard let url = url(for: api) else { return nil }
        var request = URLRequest(url: url, timeoutInterval: timeoutInterval)
        api.method.apply(to: &request)
        api.headers?.apply(to: &request)
        if case .body(let body) = api.parameters {
            body.apply(to: &request)
        }
        return request
    }

    func url<Api: HttpApiRequest>(for api: Api) -> URL? {
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

extension Publisher where Output == URLSession.DataTaskPublisher.Output {
    func validateStatusCode() -> AnyPublisher<Output, Error> {
        return self
            .tryMap {
                guard let httpResponse = $0.response as? HTTPURLResponse, (200..<300) ~= httpResponse.statusCode else {
                    throw HttpError.invalidStatusCode
                }
                return $0
            }
            .eraseToAnyPublisher()
    }
}
