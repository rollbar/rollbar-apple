import Foundation

/// A formatting micro-DSL to build complex multiline strings.
///
/// Example:
/// ```
/// Formatted {
///     "This is a line."          // <- newline suffix \n not needed
///     "This is another line."
///     ""                         // <- This is an empty line
///                                // <- This is ignored by the DSL
///     nil                        // <- Nil strings are ignored as well
///
///     if let object = maybe {    // Conditional
///         "\(object)"
///     }
///
///     for e in elements {        // Iteration
///         "\(e)"
///     }
///
///     let foo = "A string!"      // Let support
///     "Contents of foo: \(foo)"  // Standard interpolation
///     "Contents of foo: " + foo  // Additive interpolation
///
///     let bar: String? = nil
///     "Contents of foo:" *? bar   // Multiplicative interpolation, (a * nil = nil)
///
///     ["Hello", "World"]          // Array
///
///     Formatted {                 // Nesting
///         "Another section."
///     }
/// }
/// ```
///
/// - Note: There's a semantic difference between the empty string and a `nil` String.
///         the empty string always becomes an empty line, whereas a `nil` string
///         gets ignored by the formatter.
///
/// - Tag: DSL
struct Formatted<T> {
    /// The formatted string.
    ///
    /// An empty string represents an empty line, a nil string represents abscence, and
    /// won't be turned into an empty line, but ignored by nested formatters, or when
    /// joining a collection of strings or formatters.
    let string: T?

    /// Creates a new instance of a formatted string with the given string.
    init(string: T?) {
        self.string = string
    }

    /// Creates a new instance of a formatted multiline string using the ``FormatBuilder``.
    init(@FormatBuilder<T> format: () -> Formatted<T>) {
        self.string = format().string
    }
}

extension Formatted: CustomStringConvertible where T: StringProtocol {
    var description: String {
        "Format {\n\t\(self.string?.replacing("\n", with: "\n\t") ?? "\t.none")\n}"
    }
}

extension Collection {

    /// Joins a collection of formatted multiline strings into one formatted multiline string.
    func joined<T: StringProtocol>(
        separator: T = ""
    ) -> Formatted<String> where Element == Formatted<T> {
        .init(string: .init(self.compactMap(\.string).joined(separator: separator)))
    }
}

// MARK: -

infix operator *? : NilCoalescingPrecedence // right assoc

extension Optional where Wrapped: StringProtocol {

    /// An associative binary operation with _multiplicative_ semantics.
    ///
    /// Optionals have a natural absorbing element `nil`, such that a multiplicative associative
    /// operation where one of the arguments is `nil` may always result in `nil`.
    ///
    ///     0 · a = 0
    ///     a · 0 = 0
    ///     a · b = ab
    ///
    /// This allows us to bail out from a string concatenation if any of the elements
    /// being concatenated are `nil`.
    ///
    /// For example:
    ///
    ///     "Hello" *? " World" // "Hello World"
    ///     "Hello" *? nil      // nil
    ///     nil *? " World"     // nil
    ///
    /// - Further reading:
    ///     - https://en.wikipedia.org/wiki/Near-semiring
    ///     - https://en.wikipedia.org/wiki/Product_(category_theory)
    @inlinable
    static func *? (lhs: Self, rhs: @autoclosure () -> Self) -> String? {
        lift(lhs, rhs()) { $0.appending($1) }
    }

    /// Concatenates a string with a value conforming to `CustomStringConvertible`
    /// by turning the value into a string.
    @inlinable
    static func *? <T>(
        lhs: Self,
        rhs: @autoclosure () -> T?
    ) -> String? where T: CustomStringConvertible {
        lift(lhs, rhs()?.description) { $0.appending($1) }
    }

    /// Concatenates a string with a value conforming to `CustomStringConvertible`
    /// by turning the value into a string.
    @inlinable
    static func *? <T>(
        lhs: T?,
        rhs: @autoclosure () -> Self
    ) -> String? where T: CustomStringConvertible {
        lift(lhs?.description, rhs()) { $0.appending($1) }
    }

    /// Concatenates a string with a pretty printed `Dictionary` value.
    @inlinable
    static func *? (lhs: Self, rhs: @autoclosure () -> Report.Map?) -> String? {
        lift(lhs, rhs()?.description) { $0.appending($1) }
    }

    /// Concatenates a string with a pretty printed `Dictionary` value.
    @inlinable
    static func *? (lhs: Report.Map?, rhs: @autoclosure () -> Self) -> String? {
        lift(lhs?.description, rhs()) { $0.appending($1) }
    }
}

extension Result where Success == Formatted<String> {

    /// Concatenates two formatted optional strings in a `Result` provided
    /// both results are a success.
    @usableFromInline
    static func *? (lhs: Self, rhs: @autoclosure () -> Self) -> Self {
        lift(lhs, rhs(), *?)
    }
}

extension Formatted where T: StringProtocol {

    /// Concatenates two formatted optional strings.
    @inlinable
    static func *? (lhs: Self, rhs: Self) -> Formatted<String> {
        .init(string: lhs.string *? rhs.string)
    }
}

extension Formatted {
    /// Concatenates two formatted optional strings.
    @inlinable
    static func *? <Success: StringProtocol, Failure: Error>(lhs: Self, rhs: Self) -> Formatted<Result<String, Failure>>
        where T == Result<Success, Failure> {
        switch (lhs.string, rhs.string) {
        case let (.failure(failure), _),
             let (_, .failure(failure)):
            Formatted<Result<String, Failure>>(string: .failure(failure))
        case (.none, _),
             (_, .none):
            Formatted<Result<String, Failure>>(string: .none)
        case let (.success(lhs), .success(rhs)):
            Formatted<Result<String, Failure>>(string: .success(lhs.appending(rhs)))
        }
    }
}

// MARK: - Formatted<String> Builder

@resultBuilder
enum FormatBuilder<T> {}

extension FormatBuilder {
    static func buildBlock<Success: StringProtocol, Failure: Error>(_ components: Formatted<T>?...) -> Formatted<Result<String, Failure>>
        where T == Result<Success, Failure> {
        buildArray(components.compact())
    }

    static func buildOptional<Success: StringProtocol, Failure: Error>(_ component: Formatted<T>?) -> Formatted<Result<Success, Failure>>
        where T == Result<Success, Failure> {
        component ?? Formatted(string: .none)
    }

    static func buildExpression<Success: StringProtocol, Failure: Error>(_ expression: ()) -> Formatted<T>
        where T == Result<Success, Failure> {
        Formatted(string: .none)
    }

    static func buildExpression<Success: StringProtocol, Failure: Error>(
        _ expression: Formatted<T>
    ) -> Formatted<T> where T == Result<Success, Failure> {
        expression
    }
    
    static func buildExpression<Success: StringProtocol, Failure: Error>(
        _ expression: Formatted<Success>?
    ) -> Formatted<T> where T == Result<Success, Failure> {
        Formatted(string: (expression?.string).map { .success($0) })
    }

    static func buildExpression<Success: StringProtocol, Failure: Error>(
        _ expression: Success?
    ) -> Formatted<T> where T == Result<Success, Failure> {
        Formatted(string: expression.map { .success($0) })
    }

    static func buildExpression<Success: StringProtocol, Failure: Error>(
        _ expression: Failure
    ) -> Formatted<T> where T == Result<Success, Failure> {
        Formatted(string: .failure(expression))
    }

    static func buildExpression<Success: StringProtocol, Failure: Error>(
        _ expression: Result<Success, Failure>?
    ) -> Formatted<T> where T == Result<Success, Failure> {
        Formatted(string: expression)
    }

    static func buildEither<Success: StringProtocol, Failure: Error>(first component: Formatted<T>?) -> Formatted<Result<Success, Failure>>
        where T == Result<Success, Failure> {
        component ?? Formatted(string: .none)
    }

    static func buildEither<Success: StringProtocol, Failure: Error>(second component: Formatted<T>?) -> Formatted<T>
        where T == Result<Success, Failure> {
        component ?? Formatted(string: .none)
    }

    static func buildArray<Success: StringProtocol, Failure: Error>(_ components: [Formatted<T>]) -> Formatted<Result<String, Failure>>
        where T == Result<Success, Failure> {
        if let failure = components.compactMap(\.string?.failure).first {
            return .init(string: .failure(failure))
        }
        return Formatted(string: .success(components.compactMap(\.string?.success).joined(separator: "\n")))
    }

    static func buildExpression<Success: StringProtocol, Failure: Error>(_ expression: Report.Map?) -> Formatted<Result<String, Failure>>
        where T == Result<Success, Failure> {
        Formatted(string: (expression?.description).map { .success($0) })
    }

    static func buildExpression<Success: StringProtocol, Failure: Error>(_ expression: Diagnostic?) -> Formatted<Result<String, Failure>>
        where T == Result<Success, Failure> {
        Formatted(string: (expression?.description).map { .success($0) })
    }
    
    static func buildExpression<S: CustomStringConvertible, Success: StringProtocol, Failure: Error>(_ expression: [S]?) -> Formatted<Result<String, Failure>>
        where T == Result<Success, Failure> {
            Formatted(string: (expression?.map(\.description).joined(separator: "\n")).map { .success($0) })
    }
}

extension FormatBuilder where T: StringProtocol {
    static func buildBlock(_ components: Formatted<T>?...) -> Formatted<String> {
        components.compact().joined(separator: "\n")
    }

    static func buildOptional(_ component: Formatted<T>?) -> Formatted<T> {
        component ?? .init(string: .none)
    }

    static func buildEither(first component: Formatted<T>?) -> Formatted<T> {
        component ?? .init(string: .none)
    }

    static func buildEither(second component: Formatted<T>?) -> Formatted<T> {
        component ?? .init(string: .none)
    }

    static func buildArray(_ components: [Formatted<T>]) -> Formatted<String> {
        components.joined(separator: "\n")
    }

    static func buildExpression(_ expression: ()) -> Formatted<T> {
        .init(string: .none)
    }

    static func buildExpression(_ expression: T?) -> Formatted<T> {
        .init(string: expression)
    }

    static func buildExpression(_ expression: [T]?) -> Formatted<String> {
        .init(string: expression?.joined(separator: "\n"))
    }

    static func buildExpression(_ expression: Formatted<T>?) -> Formatted<T> {
        expression ?? .init(string: .none)
    }

    static func buildExpression(_ expression: Report.Map?) -> Formatted<String> {
        .init(string: expression?.description)
    }

    static func buildExpression(_ expression: Diagnostic?) -> Formatted<String> {
        .init(string: expression?.description)
    }

    static func buildExpression<S>(
        _ expression: [S]?
    ) -> Formatted<String> where S: CustomStringConvertible {
        .init(string: expression?.map(\.description).joined(separator: "\n"))
    }
}
