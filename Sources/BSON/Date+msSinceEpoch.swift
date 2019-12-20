import Foundation

extension Date {
    /// The number of milliseconds after the Unix epoch that this `Date` occurs.
    public var msSinceEpoch: Int64 { return Int64((self.timeIntervalSince1970 * 1000.0).rounded()) }

    /// Initializes a new `Date` representing the instance `msSinceEpoch` milliseconds
    /// since the Unix epoch.
    public init(msSinceEpoch: Int64) {
        self.init(timeIntervalSince1970: TimeInterval(msSinceEpoch) / 1000.0)
    }
}
