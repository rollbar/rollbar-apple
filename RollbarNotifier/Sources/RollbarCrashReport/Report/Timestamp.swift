import Foundation

/// A moment in time.
struct Timestamp: RawRepresentable {
    let rawValue: Date

    /// A human-readable representation of this timestamp.
    var iso8601String: String { ISO8601Formatter().string(from: self.rawValue) }

    /// A more complete, but less readable representation of this timestamp.
    var rfc3339String: String { RFC3339Formatter().string(from: self.rawValue) }

    /// Returns a new `Timestamp` instance from a `Date` value.
    init(rawValue: Date) {
        self.rawValue = rawValue
    }

    /// Attempts to return a new `Timestamp` instance from a string holding an rfc3339 date.
    init?(rfc3339String: String) {
        guard let date = RFC3339Formatter().date(from: rfc3339String) else {
            return nil
        }

        self.rawValue = date
    }

    /// Moves this time forward in time by the given time interval.
    static func + (lhs: Self, rhs: TimeInterval) -> Self {
        .init(rawValue: lhs.rawValue + rhs)
    }

    /// Moves this time backwards in time by the given time interval.
    static func - (lhs: Self, rhs: TimeInterval) -> Self {
        .init(rawValue: lhs.rawValue - rhs)
    }
}

extension Timestamp: Equatable, Comparable, Hashable, Codable {}

private final class ISO8601Formatter: DateFormatter {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init() {
        super.init()

        self.locale = .init(identifier: "en_US_POSIX")
        self.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS ZZZ"
    }
}

private final class RFC3339Formatter: DateFormatter {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init() {
        super.init()

        self.locale = .init(identifier: "en_US_POSIX")
        self.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSSSSS'Z'"
        self.timeZone = .init(secondsFromGMT: 0)
    }
}
