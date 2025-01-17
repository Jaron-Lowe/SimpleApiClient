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
    
    /// The query items to apply to the api's request.
    var queryItems: [URLQueryItem]? { get }
    
    /// The body to apply to the api's request.
    var body: HttpBody? { get }
    
	/// The time it will take for the api to timeout.
	var timeoutInterval: TimeInterval { get }
}

// Makes headers and parameters optional.
extension HttpApiRequest {
    public var headers: HttpHeaders? {
        nil
    }
    
    public var queryItems: [URLQueryItem]? {
        nil
    }
	
	public var timeoutInterval: TimeInterval {
        30.0
	}
}
