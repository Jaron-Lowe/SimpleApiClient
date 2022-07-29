import Foundation
import Combine

public enum EventState<Success, Failure> {
    case inProgress
    case success(Success)
    case failure(Failure)
    
    var success: Success? {
        guard case .success(let value) = self else {
            return nil
        }
        return value
    }
    
    var failure: Failure? {
        guard case .failure(let value) = self else {
            return nil
        }
        return value
    }
    
    var isInProgress: Bool {
        if case .inProgress = self {
            return true
        }
        return false
    }
    
    var isSuccess: Bool {
        return (success != nil)
    }
    
    var isFailure: Bool {
        return (failure != nil)
    }
}

extension Publisher {
    func mapEventState() -> AnyPublisher<EventState<Output, Failure>, Never> {
        let result = self
            .map { EventState.success($0) }
            .catch { Just(EventState.failure($0)) }
            .prepend(EventState.inProgress)
            .eraseToAnyPublisher()
        return result
    }
}
