import Foundation

/// A representation of a `Diagnostic`.
struct Diagnostic: RawRepresentable {
    /// The `diagnosis`, this is usually an error message.
    let diagnosis: String

    /// Where the diagnosis originated from.
    let source: String

    /// A dictionary representation of the `Diagnostic`.
    var rawValue: Report.Map {
        ["diagnosis": self.diagnosis, "source": self.source]
    }

    /// Initializes a new `Diagnostic` with the given `diagnosis` and `source`.
    init<S>(_ diagnosis: S, source: String) where S: StringProtocol {
        self.diagnosis = String(diagnosis)
        self.source = source
    }

    /// Initializes a new `Diagnostic` from the given dictionary.
    ///
    /// The given dictionary must contain a `diagnosis` _and_ a `source`
    /// key with `String` values, otherwise returns `nil`.
    init?(rawValue: Report.Map) {
        guard
            let diagnosis = rawValue["diagnosis"] as? String,
            let source = rawValue["source"] as? String
        else {
            return nil
        }

        self.init(diagnosis, source: source)
    }

    /// Returns a new `Diagnostic` formatted using the given `Formatter`.
    func formatted(with formatter: Formatter) -> Self {
        let formatted = formatter.string(for: self.diagnosis) ?? self.diagnosis
        return .init(formatted, source: self.source)
    }
}
