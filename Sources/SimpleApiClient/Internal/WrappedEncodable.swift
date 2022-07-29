import Foundation

struct WrappedEncodable: Encodable {
    let wrappedValue: Encodable
    
    func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
}
