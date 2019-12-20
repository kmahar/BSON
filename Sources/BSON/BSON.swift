import Foundation

/// The possible types of BSON values and their corresponding integer values.
public enum BSONType: UInt32 {
    /// An invalid type
    case invalid = 0x00
    /// 64-bit binary floating point
    case double = 0x01
    /// UTF-8 string
    case string = 0x02
    /// BSON document
    case document = 0x03
    /// Array
    case array = 0x04
    /// Binary data
    case binary = 0x05
    /// Undefined value - deprecated
    case undefined = 0x06
    /// A MongoDB ObjectId.
    /// - SeeAlso: https://docs.mongodb.com/manual/reference/method/ObjectId/
    case objectId = 0x07
    /// A boolean.
    case bool = 0x08
    /// UTC datetime, stored as UTC milliseconds since the Unix epoch
    case datetime = 0x09
    /// Null value
    case null = 0x0A
    /// A regular expression
    case regex = 0x0B
    /// A database pointer - deprecated
    case dbPointer = 0x0C
    /// javascript code
    case code = 0x0D
    /// A symbol - deprecated
    case symbol = 0x0E
    /// javascript code w/ scope
    case codeWithScope = 0x0F
    /// 32-bit integer
    case int32 = 0x10
    /// Special internal type used by MongoDB replication and sharding
    case timestamp = 0x11
    /// 64-bit integer
    case int64 = 0x12
    /// 128-bit decimal floating point
    case decimal128 = 0x13
    /// Special type which compares lower than all other possible BSON element values
    case minKey = 0xFF
    /// Special type which compares higher than all other possible BSON element values
    case maxKey = 0x7F
}

public enum BSON {
    case double(Double)
    case string(String)
    case document(Document)
    indirect case array([BSON])
    case binary(Binary)
    case undefined
    case objectId(ObjectId)
    case bool(Bool)
    case date(Date)
    case null
    case regex(RegularExpression)
    case dbPointer(DBPointer)
    case symbol(String)
    case code(Code)
    case codeWithScope(CodeWithScope)
    case int32(Int32)
    case timestamp(Timestamp)
    case int64(Int64)
    // decimal128
    case minKey
    case maxKey

    public var doubleValue: Double? {
        guard case let .double(double) = self else {
            return nil
        }
        return double
    }

    public var stringValue: String? {
        guard case let .string(value) = self else {
            return nil
        }
        return value
    }

    public var documentValue: Document? {
        guard case let .document(value) = self else {
            return nil
        }
        return value
    }

    public var arrayValue: [BSON]? {
        guard case let .array(value) = self else {
            return nil
        }
        return value
    }

    public var binaryValue: Binary? {
        guard case let .binary(value) = self else {
            return nil
        }
        return value
    }

    public var isUndefined: Bool {
        return self == .undefined
    }

    public var objectIdValue: ObjectId? {
        guard case let .objectId(value) = self else {
            return nil
        }
        return value
    }

    public var boolValue: Bool? {
        guard case let .bool(value) = self else {
            return nil
        }
        return value
    }

    public var dateValue: Date? {
        guard case let .date(value) = self else {
            return nil
        }
        return value
    }

    public var isNull: Bool {
        return self == .null
    }

    public var regexValue: RegularExpression? {
        guard case let .regex(value) = self else {
            return nil
        }
        return value
    }

    public var dbPointerValue: DBPointer? {
        guard case let .dbPointer(value) = self else {
            return nil
        }
        return value
    }

    public var symbolValue: String? {
        guard case let .symbol(value) = self else {
            return nil
        }
        return value
    }

    public var codeWithScopeValue: CodeWithScope? {
        guard case let .codeWithScope(value) = self else {
            return nil
        }
        return value
    }

    public var int32Value: Int32? {
        guard case let .int32(value) = self else {
            return nil
        }
        return value
    }

    public var timestampValue: Timestamp? {
        guard case let .timestamp(value) = self else {
            return nil
        }
        return value
    }

    public var int64Value: Int64? {
        guard case let .int64(value) = self else {
            return nil
        }
        return value
    }

    public var isMinKey: Bool {
        return self == .minKey
    }

    public var isMaxKey: Bool {
        return self == .maxKey
    }

    public var intValue: Int? {
        switch self {
        case let .int32(value):
            return Int(value)
        case let .int64(value):
            return Int(exactly: value)
        case let .double(value):
            return Int(exactly: value)
        default:
            return nil
        }
    }

    public var extJSON: String {
        return self.bsonValue.extJSON
    }

    public var canonicalExtJSON: String {
        return self.bsonValue.canonicalExtJSON
    }

    internal var bsonValue: BSONValue {
        switch self {
        case .null:
            return BSONNull()
        case .undefined:
            return Undefined()
        case .minKey:
            return MinKey()
        case .maxKey:
            return MaxKey()
        case let .symbol(v):
            return Symbol(v)
        case let .double(v):
            return v
        case let .string(v):
            return v
        case let .document(v):
            return v
        case let .binary(v):
            return v
        case let .objectId(v):
            return v
        case let .bool(v):
            return v
        case let .date(v):
            return v
        case let .regex(v):
            return v
        case let .dbPointer(v):
            return v
        case let .code(v):
            return v
        case let .codeWithScope(v):
            return v
        case let .int32(v):
            return v
        case let .timestamp(v):
            return v
        case let .int64(v):
            return v
        case let .array(v):
            return v
        }
    }

    internal func toBSON() -> Data {
        return self.bsonValue.toBSON()
    }

    internal var bsonType: UInt8 {
        return UInt8(type(of: self.bsonValue).bsonType.rawValue)
    }
}

extension BSON: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension BSON: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}

extension BSON: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .double(value)
    }
}

extension BSON: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .int64(Int64(value))
    }
}

extension BSON: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, BSON)...) {
        self = .document(Document(elements: elements))
    }
}

extension BSON: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: BSON...) {
        self = .array(elements)
    }
}

extension BSON: Equatable {}
extension BSON: Hashable {}

extension BSON: Codable {
    public init(from decoder: Decoder) throws {
        // short-circuit when using `BSONDecoder`
        if let bsonDecoder = decoder as? _BSONDecoder {
            self = bsonDecoder.storage.topContainer.bson
            return
        }

        let container = try decoder.singleValueContainer()

        // since we aren't sure which BSON type this is, just try decoding
        // to each of them and go with the first one that succeeds
        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(String.self) {
            self = value.bson
        } else if let value = try? container.decode(Binary.self) {
            self = value.bson
        } else if let value = try? container.decode(ObjectId.self) {
            self = value.bson
        } else if let value = try? container.decode(Bool.self) {
            self = value.bson
        } else if let value = try? container.decode(RegularExpression.self) {
            self = value.bson
        } else if let value = try? container.decode(CodeWithScope.self) {
            self = value.bson
        } else if let value = try? container.decode(Int.self) {
            self = value.bson
        } else if let value = try? container.decode(Int32.self) {
            self = value.bson
        } else if let value = try? container.decode(Int64.self) {
            self = value.bson
        } else if let value = try? container.decode(Double.self) {
            self = value.bson
        } else if let value = try? container.decode(MinKey.self) {
            self = value.bson
        } else if let value = try? container.decode(MaxKey.self) {
            self = value.bson
        } else if let value = try? container.decode(Document.self) {
            self = value.bson
        } else if let value = try? container.decode(Timestamp.self) {
            self = value.bson
        } else if let value = try? container.decode(Undefined.self) {
            self = value.bson
        } else if let value = try? container.decode(DBPointer.self) {
            self = value.bson
        } else {
            throw DecodingError.typeMismatch(
                    BSON.self,
                    DecodingError.Context(
                            codingPath: decoder.codingPath,
                            debugDescription: "Encountered a value that could not be decoded to any BSON type")
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        try self.bsonValue.encode(to: encoder)
    }
}

internal protocol BSONValue: Codable {
    init(from data: inout Data) throws
    func toBSON() -> Data
    var bson: BSON { get }
    var extJSON: String { get }
    var canonicalExtJSON: String { get }
    static var bsonType: BSONType { get }
}

extension BSONValue {
    internal var extJSON: String {
        return self.canonicalExtJSON
    }
}

extension BSONValue where Self: ExpressibleByIntegerLiteral {
    internal init(from data: inout Data) throws {
        self = try readInteger(from: &data)
    }
}

extension BSONValue where Self: Numeric {
    func toBSON() -> Data {
        return withUnsafeBytes(of: self) { Data($0) }
    }

    internal var extJSON: String {
        return String(describing: self)
    }
}

extension String: BSONValue {
    internal static var bsonType: BSONType { return .string }

    internal var bson: BSON { return .string(self) }

    internal var canonicalExtJSON: String { return "\"\(self)\"" }

    internal init(from data: inout Data) throws {
        self = try readString(from: &data)
    }

    /// Given utf8-encoded `Data`, reads from the start up to the first null byte and constructs a String from it.
    /// Mutates `cStringData` to remove the parsed data from the start.
    internal init(cStringData: inout Data) throws {
        guard cStringData.count >= 1 else {
            throw InternalError(message: "Expected to get at least 1 byte, got \(cStringData.count)")
        }
        let bytes = cStringData.prefix { $0 != 0 }
        guard bytes.count < cStringData.count else {
            throw InternalError(message: "cstring buffer missing null byte")
        }
        cStringData = cStringData[(cStringData.startIndex + bytes.count + 1)...]
        guard let str = String(bytes: bytes, encoding: .utf8) else {
            throw InternalError(message: "invalid UTF-8 data")
        }
        self = str
    }

    internal func toBSON() -> Data {
        var data = Data()
        let cStringData = self.toCStringData()
        data.append(Int32(cStringData.count).toBSON())
        data.append(cStringData)
        return data
    }

    internal func toCStringData() -> Data {
        var data = Data()
        data.append(contentsOf: self.utf8)
        data.append(0)
        return data
    }
}

extension Bool: BSONValue {
    internal static var bsonType: BSONType { return .bool }

    internal var bson: BSON { return .bool(self) }

    internal var canonicalExtJSON: String { return String(self) }

    internal init(from data: inout Data) throws {
        guard data.count >= 1 else {
            throw InternalError(message: "Expected to get at least 1 byte, got \(data.count)")
        }
        let byte = data.removeFirst()
        switch byte {
        case 0:
            self = false
        case 1:
            self = true
        default:
            throw InvalidBSONError("Unable to initialize Bool from byte \(byte)")
        }
    }

    internal func toBSON() -> Data {
        return self ? Data([1]) : Data([0])
    }
}

extension Double: BSONValue {
    internal static var bsonType: BSONType { return .double }

    internal var bson: BSON { return .double(self) }

    internal var canonicalExtJSON: String {
        return "{ \"$numberDouble\": \(String(self).canonicalExtJSON) }"
    }

    public init(from data: inout Data) throws {
        guard data.count >= 8 else {
            throw InternalError(message: "Expected to get at least 8 bytes, got \(data.count)")
        }
        var value = 0.0
        _ = withUnsafeMutableBytes(of: &value) {
            data.copyBytes(to: $0)
        }
        self = value
        data.removeFirst(8)
    }
}

extension Int: BSONValue {
    /// `Int` corresponds to a BSON int32 or int64 depending upon whether the compilation system is 32 or 64 bit.
    /// Use MemoryLayout instead of Int.bitWidth to avoid a compiler warning.
    /// See: https://forums.swift.org/t/how-can-i-condition-on-the-size-of-int/9080/4
    internal static var bsonType: BSONType { return MemoryLayout<Int>.size == 4 ? .int32 : .int64 }

    internal var bson: BSON { return Int.bsonType == .int32 ? .int32(Int32(self)) : .int64(Int64(self)) }

    internal var canonicalExtJSON: String {
        return self.bson.bsonValue.canonicalExtJSON
    }
}

extension Int32: BSONValue {
    internal static var bsonType: BSONType { return .int32 }

    internal var bson: BSON { return .int32(self) }

    internal var canonicalExtJSON: String {
        return "{ \"$numberInt\": \(String(self).canonicalExtJSON) }"
    }
}

extension Int64: BSONValue {
    internal static var bsonType: BSONType { return .int64 }

    internal var canonicalExtJSON: String {
        return "{ \"$numberLong\": \(String(self).canonicalExtJSON) }"
    }

    internal var bson: BSON { return .int64(self) }
}

extension Date: BSONValue {
    // the maximum date that extJSON will format using iso8601 format
    internal static let MAX_ISO_DATE = Date(msSinceEpoch: 253370782800) // January 1, 9999

    internal static var bsonType: BSONType { return .datetime }

    internal var bson: BSON { return .date(self) }

    internal var canonicalExtJSON: String {
        return "{ \"$date\": \(self.msSinceEpoch.canonicalExtJSON) }"
    }

    internal var extJSON: String {
        if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
            if self < Date.MAX_ISO_DATE && self.timeIntervalSince1970 >= 0 {
                return "{ \"$date\": \(BSONDecoder.iso8601Formatter.string(from: self).canonicalExtJSON) }"
            }
        }
        return self.canonicalExtJSON
    }

    internal init(from data: inout Data) throws {
        self.init(msSinceEpoch: try Int64(from: &data))
    }

    internal func toBSON() -> Data {
        return self.msSinceEpoch.toBSON()
    }
}

extension Array: BSONValue where Element == BSON {
    internal static var bsonType: BSONType { return .array }

    internal var bson: BSON { return .array(self) }

    internal var canonicalExtJSON: String {
        return "[\(self.map { $0.canonicalExtJSON }.joined(separator: ", "))]"
    }

    internal var extJSON: String {
        return "[\(self.map { $0.extJSON }.joined(separator: ", "))]"
    }

    internal init(from data: inout Data) throws {
        let doc = try Document(from: &data)
        var docIter = doc.makeIterator()
        var arr: [BSON] = []
        // ignore keys to allow for degenerate BSON arrays
        while let (_, value) = try docIter.nextOrError() {
            arr.append(value)
        }

        self = arr
    }

    internal func toBSON() -> Data {
        if case let .array(arr) = self.bson {
            var doc = Document()
            for (i, element) in arr.enumerated() {
                doc[String(i)] = element
            }
            return doc.toBSON()
        }
        fatalError("can't reach here")
    }
}

/// Reads a `String` according to the "string" non-terminal of the BSON spec.
internal func readString(from data: inout Data) throws -> String {
    let length = Int(try Int32(from: &data))

    guard length >= 1 else {
        throw InvalidBSONError("string length must be at least 1 to account for terminating null byte")
    }

    guard data.count >= length else {
        throw InvalidBSONError("string length encoded as \(length), but only \(data.count) bytes left in buffer")
    }

    let lastByte = data[data.startIndex + length - 1]
    guard lastByte == 0 else {
        throw InvalidBSONError("expected last byte of String data to be null byte, got \(lastByte)")
    }

    guard let str = String(data: data[data.startIndex..<(data.startIndex + length - 1)], encoding: .utf8) else {
        throw InvalidBSONError("invalid UTF-8 data")
    }

    data.removeFirst(str.utf8.count + 1)
    return str
}

/// Reads an integer type from the data. Throws if buffer is too small.
internal func readInteger<T: ExpressibleByIntegerLiteral>(from data: inout Data) throws -> T {
    let size = MemoryLayout<T>.size
    guard data.count >= size else {
        throw InternalError(message: "Buffer not large enough to read \(T.self) from")
    }
    var value: T = 0
    _ = withUnsafeMutableBytes(of: &value) {
        data.copyBytes(to: $0)
    }
    data.removeFirst(size)
    return value
}

internal struct InvalidBSONError: LocalizedError {
    internal let message: String

    internal init(_ message: String) {
        self.message = message
    }

    public var errorDescription: String? {
        return self.message
    }
}
