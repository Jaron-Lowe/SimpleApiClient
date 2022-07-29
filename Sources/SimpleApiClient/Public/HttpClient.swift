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
    public func send<Response: Decodable>(api: HttpApiRequest, for type: Response.Type) -> AnyPublisher<EventState<Response, Error>, Never> {
        guard let request = request(for: api) else {
            return Just(EventState.failure(HttpError.malformedApi))
                .eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: type, decoder: decoder)
            .mapEventState()
    }
    
    public func send<Response: Decodable, T>(api: HttpApiRequest, for type: Response.Type, keyPath: KeyPath<Response, T>) -> AnyPublisher<EventState<T, Error>, Never> {
        guard let request = request(for: api) else {
            return Just(EventState.failure(HttpError.malformedApi))
                .eraseToAnyPublisher()
        }
        return send(request: request, for: type)
            .map { $0[keyPath: keyPath] }
            .mapEventState()
    }
}

private extension HttpClient {
    func send<Response: Decodable>(request: URLRequest, for type: Response.Type) -> AnyPublisher<Response, Error> {
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: type, decoder: decoder)
            .eraseToAnyPublisher()
    }
    
    func request(for api: HttpApiRequest) -> URLRequest? {
        guard let url = url(for: api) else { return nil }
        var request = URLRequest(url: url, timeoutInterval: timeoutInterval)
        api.method.apply(to: &request)
        api.headers?.apply(to: &request)
        if case .body(let body) = api.parameters {
            body.apply(to: &request)
        }
        return request
    }
    
    func url(for api: HttpApiRequest) -> URL? {
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
