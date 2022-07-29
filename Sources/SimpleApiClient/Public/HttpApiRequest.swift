import Foundation

public protocol HttpApiRequest {
    var endpointPath: String { get }
    var method: HttpMethod { get }
    var headers: HttpHeaders? { get }
    var parameters: HttpParameters? { get }
}
