import Foundation
//import bson

// TODO: figure out if Int.random is random enough to satisfy OID spec or if we need to pass in some custom PRNG.
// also unclear if the second 5 bytes are "process unique".

public struct ObjectId {
    /// Stores the twelve bytes of data comprising this `ObjectId`.
    ///   4 byte timestamp    5 byte process unique   3 byte counter
    /// |<----------------->|<---------------------->|<------------>|
    /// [----|----|----|----|----|----|----|----|----|----|----|----]
    /// 0                   4                   8                   12
    internal let data: Data
    /// Counter used to generate the last three bytes of each `ObjectId`.
    private static let counter = ObjectIdCounter()

    /// The timestamp used to create this `ObjectId`, represented as seconds since the Unix epoch.
    public let timestamp: UInt32

    /// This ObjectId as a hexadecimal string.
    public var hex: String {
        return self.data.hex
    }

    /// Initializes a new `ObjectId`.
    public init() {
        var data = Data(capacity: 12)

        let secondsSinceEpoch = Date().timeIntervalSince1970
        let timestamp = UInt32(secondsSinceEpoch)
        self.timestamp = timestamp
        // 4-byte big endian field represents the seconds since the Unix epoch
        withUnsafeBytes(of: timestamp.bigEndian) { bytes in
            data.append(contentsOf: bytes)
        }

        // generate a random number that uses at most 5 bytes
        let processUnique = UInt64.random(in: 0...UInt64(pow(2, 40.0)))
        // append the least significant 5 bytes
        withUnsafeBytes(of: processUnique.bigEndian) { bytes in
            data.append(contentsOf: bytes[3...7])
        }

        let counterValue = ObjectId.counter.next()
        // get the next number from the counter and append the least significant 3 bytes
        withUnsafeBytes(of: counterValue.bigEndian) { bytes in
            data.append(contentsOf: bytes[1...3])
        }
        self.data = data
    }

    /// Initializes a new `ObjectId` from a hexadecimal string. Returns `nil` if the hex string is invalid.
    public init?(_ hex: String) {
        // TODO: parse hex here ourselves rather than letting libmongoc do it.
        // guard bson_oid_is_valid(hex, hex.utf8.count) else {
        //     return nil
        // }
        // var oid_t = bson_oid_t()
        // bson_oid_init_from_string(&oid_t, hex)
        // let bytes = [UInt8](UnsafeBufferPointer(start: &oid_t.bytes.0, count: MemoryLayout.size(ofValue: oid_t.bytes)))
        // self.data = Data(bytes)
        // self.timestamp = UInt32(bson_oid_get_time_t(&oid_t))
        return nil
    }
}

extension ObjectId: CustomStringConvertible {
    public var description: String {
        return self.hex
    }
}

extension ObjectId: Equatable {}
extension ObjectId: Hashable {}
extension ObjectId: Codable {}

extension ObjectId: BSONValue {
    internal static var bsonType: BSONType { return .objectId }

    internal var bson: BSON { return .objectId(self) }

    internal var canonicalExtJSON: String {
        return "{ \"$oid\": \(self.hex.canonicalExtJSON) }"
    }

    internal init(from data: inout Data) throws {
        guard data.count >= 12 else {
            throw InternalError(message: "expected to get at least 12 bytes, got \(data.count)")
        }
        self.data = data.subdata(in: data.startIndex..<(data.startIndex + 12))
        self.timestamp = try readInteger(from: &data)
        data.removeFirst(8)
    }

    internal func toBSON() -> Data {
        return self.data
    }
}

/// Threadsafe counter that generates an increasing sequence of values for ObjectIds.
internal class ObjectIdCounter {
    private let queue = DispatchQueue(label: "ObjectId counter queue")
    /// Current count. This variable must only be read and written within `queue.sync` blocks.
    private var count = UInt32.random(in: 0...max)
    /// Maximum value this counter can return.
    private static var max = UInt32(16777215)

    /// Returns the next value in the counter.
    internal func next() -> UInt32 {
        return queue.sync {
            self.count += 1
            // When the counter overflows (i.e., hits 16777215+1), the counter MUST be reset to 0.
            if self.count > ObjectIdCounter.max {
                self.count = 0
            }
            return self.count
        }
    }
}
