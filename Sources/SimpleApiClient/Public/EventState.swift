import Foundation
import Combine

public enum EventState<Success, Failure> {
    case inProgress
    case success(Success)
    case failure(Failure)
    
    public var success: Success? {
        guard case .success(let value) = self else {
            return nil
        }
        return value
    }
    
    public var failure: Failure? {
        guard case .failure(let value) = self else {
            return nil
        }
        return value
    }
    
    public var isInProgress: Bool {
        if case .inProgress = self {
            return true
        }
        return false
    }
    
    public var isSuccess: Bool {
        return (success != nil)
    }
    
    public var isFailure: Bool {
        return (failure != nil)
    }
}

extension Publisher {
    public func mapEventState() -> AnyPublisher<EventState<Output, Failure>, Never> {
        let result = self
            .map { EventState.success($0) }
            .catch { Just(EventState.failure($0)) }
            .prepend(EventState.inProgress)
            .eraseToAnyPublisher()
        return result
    }
}
