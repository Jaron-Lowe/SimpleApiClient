import Foundation

public protocol URLRequestApplying {
    func apply(to request: inout URLRequest)
}
