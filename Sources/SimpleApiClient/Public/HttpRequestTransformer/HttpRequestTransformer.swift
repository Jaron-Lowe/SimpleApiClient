import Foundation


/// Describes a type that allows for transforming a `URLRequest` asynchronously.
public protocol HttpRequestTransformer {
    /// Transforms a `URLRequest`.
    /// - Parameters:
    ///   - request: The initial request to be transformed.
    ///   - session: The `URLSession` that will run the `URLRequest` after transformation.
    /// - Returns: A `Task` returning the transformed `URLRequest` after some async work.
    func transform(request: URLRequest, session: URLSession) -> Task<URLRequest, Error>
}
