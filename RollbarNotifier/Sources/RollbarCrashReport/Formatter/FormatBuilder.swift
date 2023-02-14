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
struct Formatted<T: StringProtocol> {
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

extension Formatted: CustomStringConvertible {

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

extension Formatted {

    /// Concatenates two formatted optional strings.
    @inlinable
    static func *? (lhs: Self, rhs: Self) -> Formatted<String> {
        .init(string: lhs.string *? rhs.string)
    }
}

// MARK: - Formatted<String> Builder

@resultBuilder
enum FormatBuilder<T: StringProtocol> {

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
