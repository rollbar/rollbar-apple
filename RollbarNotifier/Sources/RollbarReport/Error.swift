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

    /// Returns a new `NSError` stating that a `Report` contains invalid binary images,
    /// making it impossible to process the `Report`.
    static func invalidBinaryImages(
        _ report: Report,
        names: [String],
        _ file: StaticString = #file,
        _ line: UInt = #line
    ) -> Self {
        .init(domain: "\(file):\(line)", code: 10, userInfo: [
            NSLocalizedDescriptionKey: "Report has invalid binary images.",
            NSFilePathErrorKey: file,
            "invalid_binary_images": names.joined(separator: ", ")
        ])
    }

    /// Returns a new `NSError` stating that a `Report` contains at least one invalid stack address,
    /// making it impossible to process the `Report`.
    static func invalidAddress(
        _ file: StaticString = #file,
        _ line: UInt = #line
    ) -> Self {
        .init(domain: "\(file):\(line)", code: 11, userInfo: [
            NSLocalizedDescriptionKey: "Report has an invalid address.",
            NSFilePathErrorKey: file
        ])
    }

    /// Returns a new `NSError` stating that a `Report` has the incorrect version and
    /// is not supported.
    static func unsupported(
        _ report: Report,
        version: String,
        _ file: StaticString = #file,
        _ line: UInt = #line
    ) -> Self {
        .init(domain: "\(file):\(line)", code: 2, userInfo: [
            NSLocalizedDescriptionKey: "Unsupported format, invalid version.",
            NSFilePathErrorKey: file,
            "report_version": version
        ])
    }
}
