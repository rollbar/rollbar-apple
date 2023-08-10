/// This prelude exclusive aim is to improve ergonomics of the base frameworks and stdlib.
import Foundation

// MARK: - Combinators

/// The identity function.
@inlinable
func id<A>(_ a: A) -> A {
    a
}

/// The constant function.
@inlinable
func const<A, B>(_ a: A) -> (B) -> A {
    { _ in a }
}

// MARK: -

/// Returns a comparing function.
///
/// Example usage:
///
///     self.users.sorted(by: their(\.email))
@inlinable
func their<A, B>(
    _ get: @escaping (A) -> B
) -> (A, A) -> Bool where B: Comparable {
    { get($0) < get($1) }
}

extension Comparable where Self: RawRepresentable, Self.RawValue: Comparable {

    @inlinable
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Optional

/// Maps the two given `Optional` arguments to the given function if and only if
/// the arguments are not `nil`.
@inlinable
func lift<A, B, C>(
    _ a: A?,
    _ b: @autoclosure () -> B?,
    _ f: (A, B) throws -> C
) rethrows -> C? {
    guard let a = a, let b = b() else {
        return .none
    }

    return try f(a, b)
}

/// Returns an optional pair by zipping over the two given optionals.
@inlinable
func zip<A, B>(_ a: A?, _ b: B?) -> (A, B)? {
    lift(a, b) { ($0, $1) }
}

/// Returns an optional pair by zipping over the two given optionals.
@inlinable
func zip<A, B>(_ ab: (A?, B?)) -> (A, B)? {
    lift(ab.0, ab.1) { ($0, $1) }
}

/// Returns an optional triple by zipping over the three given optionals.
@inlinable
func zip<A, B, C>(_ a: A?, _ b: B?, _ c: C?) -> (A, B, C)? {
    zip(a, zip(b, c)).map { ($0, $1.0, $1.1) }
}

extension Optional {

    /// Returns the wrapped value if there is one, otherwise calls the given
    /// closure and returns the result.
    @inlinable
    func orElse(_ alt: () -> Wrapped) -> Wrapped {
        self ?? alt()
    }
}

// MARK: - Result

@inlinable
func lift<A, B, C, E>(
    _ a: Result<A, E>,
    _ b: @autoclosure () -> Result<B, E>,
    _ f: (A, B) throws -> C
) rethrows -> Result<C, E> {
    guard case .success(let a) = a, case .success(let b) = b() else {
        return .failure(a.failure ?? b().failure!)
    }

    return .success(try f(a, b))
}

/// Returns a result pair by zipping over the two given results.
@inlinable
func zip<A, B, E>(
    _ a: Result<A, E>,
    _ b: Result<B, E>
) -> Result<(A, B), E> {
    lift(a, b) { ($0, $1) }
}

extension Result {

    /// Returns a boolean stating whether this `Result` represents a case of success.
    @inlinable
    var isSuccess: Bool {
        if case .success = self { return true } else { return false }
    }

    /// Returns a boolean stating whether this `Result` represents a case of failure.
    @inlinable
    var isFailure: Bool {
        !isSuccess
    }

    /// Returns the value associated with the `Success` case or `nil` if this `Result`
    /// represents a failure.
    @inlinable
    var success: Success? {
        guard case .success(let value) = self else {
            return .none
        }
        return value
    }

    /// Returns the value associated with the `Failure` case or `nil` if this `Result`
    /// represents a success.
    @inlinable
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
    @inlinable
    func compact<Wrapped>() -> [Wrapped] where Element == Wrapped? {
        self.compactMap(id)
    }
}

extension Collection where Self.SubSequence == ArraySlice<Element> {

    /// Returns this collection split into slices of the given length.
    func chunks(of len: Self.Index) -> [ArraySlice<Element>] {
        stride(from: self.startIndex, to: self.endIndex, by: len).map {
            self[$0 ..< Swift.min($0 + len, self.endIndex)]
        }
    }
}

extension RangeReplaceableCollection {

    /// Returns the first element of this collection by removing it in-place
    /// from this collection, or `nil` if the collection is empty.
    @inlinable
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
    @inlinable
    subscript<T>(any path: String) -> T? {
        self[T.self, path]
    }

    /// Accesses the value with the given key, falling back to the given default
    /// value if the key isn't found.
    ///
    /// Use this subscript when you want either the value for a particular key
    /// or, when that key is not present in the dictionary, a default value.
    @inlinable
    subscript<T>(any path: String, default defaultValue: @autoclosure () -> T) -> T {
        self[T.self, path, default: defaultValue()]
    }

    /// Accesses the value associated with the given key for reading and writing.
    ///
    /// This *key-based* subscript returns the value for the given key if the key
    /// is found in the dictionary, or `nil` if the key is not found.
    @usableFromInline
    subscript<T>(_ type: T.Type, _ path: String) -> T? {
        let keys = path.split(separator: ".").map(String.init)
        return self.nestedLookup(keys: keys) as? T
    }

    /// Accesses the value associated with the given key for reading and writing.
    ///
    /// This *key-based* subscript returns the value for the given key if the key
    /// is found in the dictionary, or `nil` if the key is not found.
    @usableFromInline
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

// MARK: -

extension StringProtocol {

    /// Repeats the left-hand side string the given amount of times.
    @inlinable
    static func * (str: Self, n: Int) -> String {
        repeatElement(str, count: abs(n)).joined()
    }

    /// Returns the String padded to the given length with the given padding string.
    ///
    /// Use negative values to produce a left-padded string.
    func pad(_ len: Int, with pad: String = " ") -> String {
        len >= 0
            ? self + (pad * (len - self.count))
            : (pad * (abs(len) - self.count)) + self
    }

    /// Returns a new string in which all occurrences of a target string in a specified
    /// range of the string are replaced by another given string.
    @inlinable
    func replacing(_ string: String, with replacement: String) -> String {
        self.replacingOccurrences(of: string, with: replacement)
    }

    /// Returns a new string made by removing from both ends of the String characters
    /// contained in a given character set.
    @inlinable
    func trimming(_ characters: CharacterSet) -> String {
        self.trimmingCharacters(in: characters)
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

// MARK: -

/// Negates a predicate function.
@inlinable
prefix func ! <A>(rhs: @escaping (A) -> Bool) -> (A) -> Bool {
    { a in !rhs(a) }
}

extension KeyPath where Value == Bool {

    /// Negates a keyPath predicate.
    ///
    /// Example:
    ///
    ///     [[1, 2], [], [3, 4]]
    ///         .filter(!\.isEmpty)
    ///
    /// Results in
    ///
    ///     [[1, 2], [2, 3]]
    @inlinable
    static prefix func !(rhs: KeyPath) -> (Root) -> Bool {
        { root in !root[keyPath: rhs] }
    }
}

// MARK: -

extension Data {

    init?(from jsonObject: Any, options: JSONSerialization.WritingOptions = []) {
        guard let data = try? JSONSerialization.data(
            withJSONObject: jsonObject,
            options: options
        ) else {
            return nil
        }

        self = data
    }
}

// MARK: -

extension UUID {

    /// A `UUID` where all the bits are set to zero.
    static let empty: Self = .init(uuidString: "00000000-0000-0000-0000-000000000000")!
}

// MARK: -

/// Unimplemented hole that always types check.
func todo(file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError("not implemented", file: file, line: line)
}
