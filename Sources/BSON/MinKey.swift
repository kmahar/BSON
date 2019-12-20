import Foundation

internal struct MinKey {}

extension MinKey: BSONValue {
    internal static var bsonType: BSONType { return .minKey }

    internal var bson: BSON { return .minKey }

    internal var canonicalExtJSON: String {
        return "{ \"$minKey\": 1 }"
    }

    internal func toBSON() -> Data {
        return Data()
    }

    internal init(from data: inout Data) throws {}
}
