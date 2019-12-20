import Foundation

internal struct BSONNull {}

extension BSONNull: BSONValue {
    internal static var bsonType: BSONType { return .null }

    internal var bson: BSON { return .null }
    internal var canonicalExtJSON: String {
        return "null"
    }

    internal func toBSON() -> Data {
        return Data()
    }

    internal init(from data: inout Data) throws {}
}
