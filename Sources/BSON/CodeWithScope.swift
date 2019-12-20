import Foundation

public struct Code: Equatable, Hashable, Codable {
    /// A string containing code code.
    public let code: String

    /// Initializes a `CodeWithScope`.
    public init(code: String) {
        self.code = code
    }
}

extension Code: BSONValue {
    internal static var bsonType: BSONType { return .code }

    internal var bson: BSON { return .code(self) }

    internal var canonicalExtJSON: String {
        return "{ \"$code\": \(self.code.canonicalExtJSON) }"
    }

    internal init(from data: inout Data) throws {
        self.code = try readString(from: &data)
    }

    internal func toBSON() -> Data {
        return self.code.toBSON()
    }
}

public struct CodeWithScope: Equatable, Hashable, Codable {
    /// A string containing code code.
    public let code: String
    /// An optional scope `Document` containing a mapping of identifiers to values,
    /// representing the context in which `code` should be evaluated.
    public let scope: Document

    /// Initializes a `CodeWithScope`.
    public init(code: String, scope: Document) {
        self.code = code
        self.scope = scope
    }
}

extension CodeWithScope: BSONValue {
    internal static var bsonType: BSONType { return .codeWithScope }

    internal var bson: BSON { return .codeWithScope(self) }

    internal var canonicalExtJSON: String {
        return "{ \"$code\": \(self.code.canonicalExtJSON), \"$scope\": \(self.scope.canonicalExtJSON) }"
    }

    internal var extJSON: String {
        return "{ \"$code\": \(self.code.canonicalExtJSON), \"$scope\": \(self.scope.extJSON) }"
    }

    internal init(from data: inout Data) throws {
        _ = try Int32(from: &data)
        self.code = try readString(from: &data)
        self.scope = try Document(from: &data)

    }

    internal func toBSON() -> Data {
        let encodedCode = self.code.toBSON()
        let encodedScope = scope.toBSON()
        let byteLength = Int32(4 + encodedCode.count + encodedScope.count).toBSON()
        return byteLength + encodedCode + encodedScope
    }
}
