struct Parser<Input, Output> {
    let parse: (inout Input) -> Output?

    func parse(_ input: Input) -> (match: Output?, rest: Input) {
        var input = input
        let output = parse(&input)
        return (output, input)
    }
}

extension Parser {
    func map<B>(
        _ f: @escaping (Output) -> B
    ) -> Parser<Input, B> {
        .init { input in
            parse(&input).map(f)
        }
    }

    func ap<B>(
        _ f: Parser<Input, (Output) -> B>
    ) -> Parser<Input, B> {
        .init { input in
            parse(&input).map { x in f.map { f in f(x) } }?.parse(&input)
        }
    }

    func bind<B>(
        _ f: @escaping (Output) -> Parser<Input, B>
    ) -> Parser<Input, B> {
        .init { input in
            parse(&input).map(f)?.parse(&input)
        }
    }

    func flatten<B>() -> Parser<Input, B> where Output == Parser<Input, B> {
        bind(id)
    }

    func zip<B>(
        _ b: Parser<Input, B>
    ) -> Parser<Input, (Output, B)> {
        .init { input in
            let original = input
            return self.parse(&input).flatMap { a in
                b.parse(&input).map { b in
                    (a, b)
                }
            }.orElse {
                input = original
                return .none
            }
        }
    }
}

extension Parser {
    static func always(_ output: Output) -> Self {
        .init(parse: const(output))
    }

    static var never: Self {
        .init(parse: const(.none))
    }

    static func oneOf(_ parsers: Self...) -> Self {
        .init { input in
            parsers.findMap { $0.parse(&input) }
        }
    }

    static func optional<A>(
        _ parser: Parser<Input, A>
    ) -> Self where Output == A? {
        .init { input in
            .some(parser.parse(&input))
        }
    }

    func many(sep: Parser<Input, ()> = .always(())) -> Parser<Input, [Output]> {
        .init { input in
            var rest = input
            var matches: [Output] = []
            while let match = parse(&input) {
                rest = input
                matches.append(match)
                if sep.parse(&input) == nil {
                    return matches
                }
            }

            input = rest
            return matches
        }
    }

    static func skip(
        _ p: Self
    ) -> Parser<Input, ()> {
        p.map(const(()))
    }

    func skip<B>(
        _ p: Parser<Input, B>
    ) -> Parser<Input, Output> {
        zip(p).map(first)
    }

    func take<B>(
        _ p: Parser<Input, B>
    ) -> Parser<Input, (Output, B)> {
        zip(p)
    }

    func take<A>(
        _ p: Parser<Input, A>
    ) -> Parser<Input, A> where Output == () {
        zip(p).map(second)
    }

    func take<A, B, C>(
        _ p: Parser<Input, C>
    ) -> Parser<Input, (A, B, C)> where Output == (A, B) {
        zip(p).map { ab, c in (ab.0, ab.1, c) }
    }
}

// MARK: - Collections

extension Parser where Input: RangeReplaceableCollection {
    var stream: Parser<AnyIterator<Input>, [Output]> {
        .init { stream in
            var buffer = Input()
            var outputs: [Output] = []

            while let chunk = stream.next() {
                buffer.append(contentsOf: chunk)
                while let output = parse(&buffer) {
                    outputs.append(output)
                }
            }

            return outputs
        }
    }

    func parse(
        input: inout AnyIterator<Input>,
        output streamOut: @escaping (Output) -> ()
    ) {
        var buffer = Input()
        while let chunk = input.next() {
            buffer.append(contentsOf: chunk)
            while let output = parse(&buffer) {
                streamOut(output)
            }
        }
    }
}

extension Parser where Output == () {
    func many(sep: Parser<Input, ()> = .always(())) -> Parser<Input, Output> {
        .init { input in
            var rest = input
            while let _ = parse(&input) {
                rest = input
                if sep.parse(&input) == nil {
                    return ()
                }
            }

            input = rest
            return ()
        }
    }
}

extension Parser
where
    Input: Collection,
    Input.Element: Equatable,
    Input == Input.SubSequence,
    Output == ()
{
    static func prefix(_ p: Input.SubSequence) -> Self {
        Self { input in
            input.starts(with: p) ? input.removeFirst(p.count) : .none
        }
    }
}

extension Parser
where
    Input: Collection,
    Input == Input.SubSequence,
    Output == Input
{
    static func prefix(while p: @escaping (Input.Element) -> Bool) -> Self {
        Self { input in
            let output = input.prefix(while: p)
            input.removeFirst(output.count)
            return output
        }
    }
}

extension Parser
where
    Input: Collection,
    Input.Element: Equatable,
    Input == Input.SubSequence,
    Output == Input
{
    static func prefix(upTo s: Input.SubSequence) -> Self {
        Self { input in
            guard !s.isEmpty else { return s }
            let original = input
            while !input.isEmpty {
                if input.starts(with: s) {
                    return original[..<input.startIndex]
                }

                input.removeFirst()
            }

            input = original
            return .none
        }
    }

    static func prefix(through s: Input.SubSequence) -> Self {
        Self { input in
            guard !s.isEmpty else { return s }
            let original = input
            while !input.isEmpty {
                if input.starts(with: s) {
                    let index = input.index(input.startIndex, offsetBy: s.count)
                    input = input[index...]
                    return original[..<index]
                }

                input.removeFirst()
            }

            input = original
            return .none
        }
    }
}

extension Parser where Input == [String: String] {
    static func key(_ key: String, _ parser: Parser<Substring, Output>) -> Self {
        Self { dict in
            guard
                var value = dict[key]?[...],
                let output = parser.parse(&value)
            else {
                return .none
            }
            dict[key] = value.isEmpty ? .none : String(value)
            return output
        }
    }
}

// MARK: - Input == Substring, Output == Int

extension Parser where Input == Substring, Output == Int {
    static let int = Self { input in
        let original = input

        var isFirstChar = true
        let prefix = input.prefix { char in
            defer { isFirstChar = false }
            return ["-", "+"].contains(char) && isFirstChar || char.isNumber
        }

        guard let output = Int(prefix) else {
            input = original
            return .none
        }

        input.removeFirst(prefix.count)
        return output
    }

    static let even = int.bind { n in
        n.isMultiple(of: 2) ? .always(n) : .never
    }
}

// MARK: - Input == Substring, Output == Double

extension Parser where Input == Substring, Output == Double {
    static let double = Self { input in
        let original = input

        var isFirstChar = true
        var decimalCount = 0
        let prefix = input.prefix { char in
            defer { isFirstChar = false }
            if char == "." { decimalCount += 1 }
            return ["-", "+"].contains(char) && isFirstChar
                || char.isNumber
                || char == "." && decimalCount <= 1
        }

        guard let output = Double(prefix) else {
            input = original
            return .none
        }

        input.removeFirst(prefix.count)
        return output
    }
}

// MARK: - Input == Substring, Output == ()

extension Parser: ExpressibleByStringLiteral where Input == Substring, Output == () {
    typealias StringLiteralType = String

    init(stringLiteral value: StringLiteralType) {
        self = .prefix(value[...])
    }
}

extension Parser: ExpressibleByUnicodeScalarLiteral where Input == Substring, Output == () {
    typealias UnicodeScalarLiteralType = String
}

extension Parser: ExpressibleByExtendedGraphemeClusterLiteral where Input == Substring, Output == () {
    typealias ExtendedGraphemeClusterLiteralType = String
}

// MARK: - Input == Substring, Output == Character

extension Parser where Input == Substring, Output == Character {
    static let char = Self { input in
        input.isEmpty ? .none : input.removeFirst()
    }
}

// MARK: - Input == Substring, Output == Substring

extension Parser where Input == Substring, Output == Substring {
    static var rest: Self {
        Self { input in
            let rest = input
            input = ""
            return rest
        }
    }

    static func prefix(while p: @escaping (Input.Element) -> Bool) -> Self {
        Self { input in
            let output = input.prefix(while: p)
            input.removeFirst(output.count)
            return output
        }
    }

    static func prefix(upTo s: Input.SubSequence) -> Self {
        Self { input in
            input.range(of: s).map { r in
                defer { input = input[r.lowerBound...] }
                return input[..<r.lowerBound]
            }
        }
    }

    static func prefix(through s: Input.SubSequence) -> Self {
        Self { input in
            input.range(of: s).map { r in
                defer { input = input[r.upperBound...] }
                return input[..<r.upperBound]
            }
        }
    }
}
