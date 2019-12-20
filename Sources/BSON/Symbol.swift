import Foundation

/// A struct to represent the deprecated Symbol type.
/// Symbols cannot be instantiated, but they can be read from existing documents that contain them.
internal struct Symbol: CustomStringConvertible, Codable {
    public var description: String {
        return stringValue
    }

    /// String representation of this `Symbol`.
    public let stringValue: String

    internal init(_ stringValue: String) {
        self.stringValue = stringValue
    }
}

extension Symbol: Equatable {}

extension Symbol: Hashable {}

extension Symbol: BSONValue {
    internal static var bsonType: BSONType { return .symbol }

    internal var bson: BSON { return .symbol(self.stringValue) }

    internal var canonicalExtJSON: String {
        return "{ \"$symbol\": \(self.stringValue.canonicalExtJSON) }"
    }

    internal init(from data: inout Data) throws {
        self.stringValue = try String(from: &data)
    }

    internal func toBSON() -> Data {
        return self.stringValue.toBSON()
    }
}