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
    
    func apply(to request: inout URLRequest) {
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
            
            var body = Data()
            
            // Add headers
            let headerString = [
                "--\(boundary)",
                "Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(UUID().uuidString)\(imageMimeType.fileExtension)\"",
                "Content-Type: \(imageMimeType.contentType)",
                "", // Empty line to create \r\n\r\n before binary data
            ].joined(separator: "\r\n")
            
            if let headerData = headerString.data(using: .utf8) {
                body.append(headerData)
                body.append("\r\n".data(using: .utf8)!) // The second \r\n after headers
            }
            
            // Add binary data
            body.append(imageData)
            
            // Add closing boundary
            if let closingBoundary = "\r\n--\(boundary)--\r\n".data(using: .utf8) {
                body.append(closingBoundary)
            }
            
            request.httpBody = body
            
        }
    }
}

extension HttpBody {
	/// Represents a mime type of an image.
	public enum BinaryImageMimeType {
		case jpg
		case png
		case custom(mimeType: String)
		
		public var contentType: String {
			switch self {
			case .jpg:
				return "image/jpeg"
			case .png:
				return "image/png"
			case .custom(let mimeType):
				return mimeType
			}
		}
		
		public var fileExtension: String {
			switch self {
			case .jpg:
				return ".jpg"
			case .png:
				return ".png"
			case .custom:
				return "" // Custom types may not have a standard extension
			}
		}
	}
}
