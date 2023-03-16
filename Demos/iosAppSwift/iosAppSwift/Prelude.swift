import Foundation

extension String {
    var isValid: Bool {
        #"(^[a-f0-9]{32}$)"#.matches(in: self)?.count == 1
    }
}

extension StringProtocol {

    /// Returns an array of `Substring`s by matching the given `String` using
    /// this string as a regular expression pattern.
    ///
    /// Returns `nil` if this string isn't a valid regex pattern, if no
    /// matches are found, an empty string is returned.
    func matches(in str: String) -> [Substring]? {
        let regex = try? NSRegularExpression(pattern: String(self))
        let range = NSRange(str.startIndex..<str.endIndex, in: str)
        return regex?.matches(in: str, range: range).first?.groups(in: str)
    }
}

extension NSTextCheckingResult {

    /// Returns an array of `Substring`s by extracting from the given `String`
    /// the groups in this `NSTextCheckingResult` instance .
    func groups(in str: String) -> [Substring] {
        guard self.numberOfRanges > 1 else { return [] }

        var result = ContiguousArray<Substring>()
        result.reserveCapacity(self.numberOfRanges)

        for index in 1..<self.numberOfRanges {
            if let substr = range(at: index, in: str).map({ str[$0] }) {
                result.append(substr)
            }
        }

        return [Substring](result)
    }

    /// Returns the `Range` for the given group number that corresponds to
    /// the given `String`.
    func range(at index: Int, in string: String) -> Range<String.Index>? {
        Range(self.range(at: index), in: string)
    }
}
