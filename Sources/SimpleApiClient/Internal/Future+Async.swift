import Foundation
import Combine

extension Future where Failure == Error {
	/// Allows for wrapping a `Task` operation into a `Combine` publisher.
	convenience init(operation: @escaping () async throws -> Output) {
		self.init { promise in
			Task {
				do {
					let output = try await operation()
					promise(.success(output))
				}
				catch {
					promise(.failure(error))
				}
			}
		}
	}
}
