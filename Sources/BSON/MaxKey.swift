import Foundation

internal struct MaxKey {}

extension MaxKey: BSONValue {
    internal static var bsonType: BSONType { return .maxKey }

    internal var bson: BSON { return .maxKey }

    internal var canonicalExtJSON: String {
        return "{ \"$maxKey\": 1 }"
    }

    internal func toBSON() -> Data {
        return Data()
    }

    internal init(from data: inout Data) throws {}
}
