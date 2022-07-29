import Foundation
import Combine


/// A value that represents an asynchronous result, including a result that is still in progress.
public enum AsyncResult<Success, Failure> {
    case inProgress
    case success(Success)
    case failure(Failure)
    
    /// Returns the value associated with a success result.
    public var successValue: Success? {
        guard case .success(let value) = self else {
            return nil
        }
        return value
    }
    
    /// Returns the value associated with a failure result.
    public var failureValue: Failure? {
        guard case .failure(let value) = self else {
            return nil
        }
        return value
    }
    
    /// Returns whether the result is still in progress.
    public var isInProgress: Bool {
        if case .inProgress = self {
            return true
        }
        return false
    }
    
    /// Returns whether the result is a success.
    public var isSuccess: Bool {
        return (successValue != nil)
    }
    
    /// Returns whether the result is a faillure.
    public var isFailure: Bool {
        return (failureValue != nil)
    }
}

extension Publisher {
    /// Transforms a publisher with concrete Output and Failure types to a new publisher that wraps Output and Failure into an AsyncResult.
    /// The new publisher is prepended with an AsyncResult.InProgress.
    /// - Returns: A type-erased publisher of type `<AsyncResult<Output, Failure>, Never>`.
    public func mapToAsyncResult() -> AnyPublisher<AsyncResult<Output, Failure>, Never> {
        return self
            .map { AsyncResult.success($0) }
            .catch { Just(AsyncResult.failure($0)) }
            .prepend(AsyncResult.inProgress)
            .eraseToAnyPublisher()
    }
}
