import Foundation

// MARK: - Combinators

/// The identity function.
func id<A>(_ a: A) -> A {
    a
}

/// The constant function.
func const<A, B>(_ a: A) -> (B) -> A {
    { _ in a }
}

/// Negates a predicate function
func not<A>(_ p: @escaping (A) -> Bool) -> (A) -> Bool {
    { a in !p(a) }
}

// MARK: - Optional

/// Returns an optional pair by zipping over the two given optionals.
func zip<A, B>(_ a: A?, _ b: @autoclosure () -> B?) -> (A, B)? {
    guard let a = a, let b = b() else {
        return .none
    }

    return (a, b)
}

/// Returns an optional triple by zipping over the three given optionals.
func zip<A, B, C>(_ a: A?, _ b: B?, _ c: C?) -> (A, B, C)? {
    zip(a, zip(b, c)).map { ($0, $1.0, $1.1) }
}

// MARK: - Result

extension Result {

    /// Returns a boolean stating whether this `Result` represents a case of success.
    var isSuccess: Bool {
        if case .success = self { return true } else { return false }
    }

    /// Returns a boolean stating whether this `Result` represents a case of failure.
    var isFailure: Bool {
        !isSuccess
    }

    /// Returns the value associated with the `Success` case or `nil` if this `Result`
    /// represents a failure.
    var success: Success? {
        guard case .success(let value) = self else {
            return .none
        }
        return value
    }

    /// Returns the value associated with the `Failure` case or `nil` if this `Result`
    /// represents a success.
    var failure: Failure? {
        guard case .failure(let error) = self else {
            return .none
        }
        return error
    }
}

// MARK: -

extension Sequence {

    /// Returns an array containing the non-`nil` elements in this sequence
    /// of `Optional` values.
    func compact<Wrapped>() -> [Wrapped] where Element == Wrapped? {
        self.compactMap(id)
    }
}

extension RangeReplaceableCollection {

    /// Returns the first element of this collection by removing it in-place
    /// from this collection, or `nil` if the collection is empty.
    mutating func popFirst() -> Element? {
        self.isEmpty ? .none : self.removeFirst()
    }
}

// MARK: -

extension Dictionary where Key == String, Value: Any {

    /// Accesses the value associated with the given key for reading and writing.
    ///
    /// This *key-based* subscript returns the value for the given key if the key
    /// is found in the dictionary, or `nil` if the key is not found.
    subscript<T>(any path: String) -> T? {
        self[T.self, path]
    }

    /// Accesses the value with the given key, falling back to the given default
    /// value if the key isn't found.
    ///
    /// Use this subscript when you want either the value for a particular key
    /// or, when that key is not present in the dictionary, a default value.
    subscript<T>(any path: String, default defaultValue: @autoclosure () -> T) -> T {
        self[T.self, path, default: defaultValue()]
    }

    /// Accesses the value associated with the given key for reading and writing.
    ///
    /// This *key-based* subscript returns the value for the given key if the key
    /// is found in the dictionary, or `nil` if the key is not found.
    subscript<T>(_ type: T.Type, _ path: String) -> T? {
        let keys = path.split(separator: ".").map(String.init)
        return self.nestedLookup(keys: keys) as? T
    }

    /// Accesses the value associated with the given key for reading and writing.
    ///
    /// This *key-based* subscript returns the value for the given key if the key
    /// is found in the dictionary, or `nil` if the key is not found.
    subscript<T>(_ type: T.Type, _ path: String, default defaultValue: @autoclosure () -> T) -> T {
        let keys = path.split(separator: ".").map(String.init)
        return self.nestedLookup(keys: keys) as? T ?? defaultValue()
    }

    /// Returns a value in this dictionary instance by performing a recursive search.
    private func nestedLookup(keys: [String]) -> Value? {
        var keys = keys
        return keys.popFirst().flatMap { key in
            if keys.isEmpty {
                return self[key]
            } else {
                let innerDict = self[key] as? Self
                return innerDict?.nestedLookup(keys: keys)
            }
        }
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
