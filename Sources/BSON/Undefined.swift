import Foundation

internal struct Undefined {}

extension Undefined: BSONValue {
    internal static var bsonType: BSONType { return .undefined }

    internal var bson: BSON { return .undefined }
    internal var canonicalExtJSON: String {
        return "{ \"$undefined\": true }"
    }

    internal func toBSON() -> Data {
        return Data()
    }

    internal init(from data: inout Data) throws {}
}
