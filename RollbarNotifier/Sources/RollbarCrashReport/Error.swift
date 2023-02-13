import Foundation

extension Error where Self == NSError {

    /// Returns a new `NSError` that describes a type-related error when trying to read
    /// a `Report` that's not a `Dictionary`.
    ///
    /// This could happen if, for instance, the ordering of the filterings is incorrect and
    /// the diagnostics filter receives an already formatted `String` crash report instead
    /// of a `Dictionary`.
    static func invalidType(
        _ report: Any,
        _ file: StaticString = #file,
        _ line: UInt = #line
    ) -> Self {
        .init(domain: "\(file):\(line)", code: 0, userInfo: [
            NSLocalizedDescriptionKey: "Report must be a Dictionary.",
            NSFilePathErrorKey: file,
            "report": "\(type(of: report))"
        ])
    }

    /// Returns a new `NSError` stating that a `Report` has missing certain keys that are
    /// indispensable to process the `Report`.
    static func missingKeys(
        _ report: Report,
        keys: [String],
        _ file: StaticString = #file,
        _ line: UInt = #line
    ) -> Self {
        .init(domain: "\(file):\(line)", code: 1, userInfo: [
            NSLocalizedDescriptionKey: "Report has missing keys required.",
            NSFilePathErrorKey: file,
            "missing_keys": keys.joined(separator: ", ")
        ])
    }
}
