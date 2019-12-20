import Foundation

/// A struct to represent the deprecated DBPointer type.
/// DBPointers cannot be instantiated, but they can be read from existing documents that contain them.
public struct DBPointer: Codable {
    // TODO: update this to MongoNamespace
    /// Destination namespace of the pointer.
    public let ref: String

    /// Destination _id (assumed to be an `ObjectId`) of the pointed-to document.
    public let id: ObjectId

    internal init(ref: String, id: ObjectId) {
        self.ref = ref
        self.id = id
    }
}

extension DBPointer: Equatable {}

extension DBPointer: Hashable {}

extension DBPointer: BSONValue {
    internal static var bsonType: BSONType { return .dbPointer }

    internal var bson: BSON { return .dbPointer(self) }
    internal var canonicalExtJSON: String {
        return "{ \"$dbPointer\": { \"$ref\": \(self.ref.canonicalExtJSON), \"$id\": \(self.id.canonicalExtJSON) } }"
    }

    internal init(from data: inout Data) throws {
        guard data.count >= 5 + 12 else {
            throw InternalError(message: "expected to get at least 17 bytes, got \(data.count)")
        }
        let ref = try readString(from: &data)
        let id = try ObjectId(from: &data)
        self.init(ref: ref, id: id)
    }

    internal func toBSON() -> Data {
        var data = self.ref.toBSON()
        data.append(self.id.toBSON())
        return data
    }
}
