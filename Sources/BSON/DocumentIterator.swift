import Foundation

extension Document: Sequence {
    public typealias Iterator = DocumentIterator

    public func makeIterator() -> DocumentIterator {
        return DocumentIterator(over: self)
    }
}

public struct DocumentIterator: IteratorProtocol {
    /// The data we are iterating over.
    private var data: Data

    internal init(over document: Document) {
        /// Skip the first 4 bytes as they contain the length.
        self.data = document.data.dropFirst(4)
    }

    public mutating func next() -> (String, BSON)? {
        do {
            return try self.nextOrError()
        } catch {
            fatalError("error reading next value from iterator: \(error)")
        }
    }

    /// Attempts to get the next value in the iterator, or throws an error if
    /// the BSON is invalid/unparseable.
    internal mutating func nextOrError() throws -> (String, BSON)? {
        guard self.data.count >= 1 else {
            throw InvalidBSONError("document is missing terminating byte")
        }

        let first = self.data.removeFirst()

        // We hit the null byte at the end of the document.
        guard first != 0 else {
            return nil
        }

        guard let bsonType = BSONType(rawValue: UInt32(first)) else {
            throw InvalidBSONError("unrecognized BSON type \(first)")
        }
        guard let swiftType = typeMap[bsonType] else {
            throw InvalidBSONError("unsupported BSON type \(bsonType)")
        }

        let key = try String(cStringData: &self.data)
        let value = try swiftType.init(from: &self.data)
        return (key, value.bson)
    }
}

let typeMap: [BSONType: BSONValue.Type] = [
    .double: Double.self,
    .string: String.self,
    .document: Document.self,
    .array: [BSON].self,
    .binary: Binary.self,
    .undefined: Undefined.self,
    .objectId: ObjectId.self,
    .bool: Bool.self,
    .datetime: Date.self,
    .null: BSONNull.self,
    .regex: RegularExpression.self,
    .dbPointer: DBPointer.self,
    .code: Code.self,
    .codeWithScope: CodeWithScope.self,
    .symbol: Symbol.self,
    .int32: Int32.self,
    .int64: Int64.self,
    .timestamp: Timestamp.self,
    .minKey: MinKey.self,
    .maxKey: MaxKey.self
]

// // first byte of the first ename.
// var idx = 5
// while true {
//     // we've reached the end of the doc.
//     if idx >= self.byteLength - 1 {
//         return nil
//     }

//     // read the next key.
//     let keyName = String(cStringData: self.data[idx...])
//     guard keyName == key else {
//         let bsonType = self.data[idx - 1]
//         idx += keyName.utf.count + 1
//         switch bsonType {
//         // undefined, null, minkey, maxkey are 0 bytes
//         case 0x06, 0x0A, 0xFF, 0x7F:
//             idx += 0
//         // bool
//         case 0x08:
//             idx += 1
//         // int32
//         case 0x10:
//             idx += 4
//         // double, int64, uint64 are 8 bytes
//         case 0x01, 0x09, 0x11:
//             idx += 8
//         // string, document, array
//         case 0x02, 0x03, 0x04:
//             idx += 0 // todo get len
//         // binary
//         case 0x05:
//             idx += 0 // get binsry len

//         }
//     }

//     // read value out here
//     return nil
// }
