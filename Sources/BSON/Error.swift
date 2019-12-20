import Foundation

public struct InvalidArgumentError: LocalizedError {
    public let message: String
}

public struct InternalError: LocalizedError {
    public let message: String
}