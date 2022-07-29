import Foundation


/// A protocol that represents the request details of an HTTP API.
public protocol HttpApiRequest {
    associatedtype ResponseType: Decodable
    
    /// A path representing the api, excluding a baseUrl.
    var endpointPath: String { get }
    
    /// The action method of the api's request.
    var method: HttpMethod { get }
    
    /// The headers to apply to the api's request.
    var headers: HttpHeaders? { get }
    
    /// The parameters to apply to the api's request.
    var parameters: HttpParameters? { get }
}

// Makes headers and parameters optional.
extension HttpApiRequest {
    var headers: HttpHeaders? { return nil }
    var parameters: HttpParameters? { return nil }
}
