import Foundation

/// Represents an HTTP Request body.
public enum HttpBody {
    /// Represents a url encoded form body.
    case form(body: [String: String])
    
    /// Represents a json encoded body.
    case json(body: Encodable)
	
	/// Represents a multipart/form image body.
	case binaryImage(imageData: Data, name: String, imageMimeType: BinaryImageMimeType)
	        
    /// The content type value associated with the body.
    var contentType: String {
        switch self {
        case .form:
            return "application/x-www-form-urlencoded charset=utf-8"
        case .json:
            return "application/json"
		case .binaryImage:
			return "multipart/form-data; charset=utf-8; boundary={{boundary}}"
        }
    }
	
	var multipartBoundary: String {
		let generateRandom = { UInt32.random(in: .min ... .max) }
		return String(format: "----%08x%08x", generateRandom(), generateRandom())
	}
}

extension HttpBody {
	/// Represents a mime type of an image.
	public enum BinaryImageMimeType {
		case jpg
		case png
		case custom(mimeType: String)
		
		var contentType: String {
			switch self {
			case .jpg:
				return "image/jpeg"
			case .png:
				return "image/png"
			case .custom(let mimeType):
				return mimeType
			}
		}
	}
}

extension HttpBody: URLRequestApplying {
    /// Applies the `HttpBody` to a request object.
    /// - Parameter request: A request for which to apply the body.
    public func apply(to request: inout URLRequest) {
		switch self {
		case .form(let body):
			var components = URLComponents()
			components.queryItems = body.map { URLQueryItem(name: $0.key, value: $0.value) }
			request.httpBody = components.query?.data(using: .utf8)
			request.addValue(contentType, forHTTPHeaderField: "Content-Type")
			
		case .json(let body):
			let wrappedBody = WrappedEncodable(wrappedValue: body)
			let encoder = JSONEncoder()
			let data = try? encoder.encode(wrappedBody)
			request.httpBody = data
			request.addValue(contentType, forHTTPHeaderField: "Content-Type")
			
		case .binaryImage(let imageData, let name, let imageMimeType):
			let boundary = multipartBoundary
			request.addValue(contentType.replacingOccurrences(of: "{{boundary}}", with: boundary), forHTTPHeaderField: "Content-Type")
			request.httpBody = {
				return [
					[
						"--\(boundary)",
						"Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(UUID().uuidString)\"",
						"Content-Type: \(imageMimeType)",
						"\r\n",
					].joined(separator: "\r\n").data(using: .utf8)!,
					imageData,
					"\r\n--\(boundary)--\r\n".data(using: .utf8)!
				].reduce(into: Data()) { partialResult, data in
					partialResult.append(data)
				}
			}()
			
		}
    }
}
