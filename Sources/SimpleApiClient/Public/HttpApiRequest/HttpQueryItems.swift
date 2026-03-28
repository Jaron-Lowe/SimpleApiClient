import Foundation

/// A list of query items.
public typealias HttpQueryItems = [URLQueryItem]

extension HttpQueryItems {
     func apply(to request: inout URLRequest) {
         guard let url = request.url else { return }
         if #available(iOS 16.0, *) {
             request.url = url.appending(queryItems: self)
         } else {
             guard let url = request.url, var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
             components.queryItems = self
             request.url = components.url
         }
    }
}
