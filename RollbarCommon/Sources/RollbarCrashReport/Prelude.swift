@inlinable
@inline(__always)
func id<A>(_ a: A) -> A {
    a
}

@inlinable
@inline(__always)
func const<A, B>(_ a: A) -> (B) -> A {
    { _ in a }
}

@inlinable
@inline(__always)
func const<A, B>(_ a: A) -> (inout B) -> A {
    { _ in a }
}

@inlinable
@inline(__always)
func const<A>(_ a: A) -> () -> A {
    { a }
}

@inlinable
@inline(__always)
func map<A, B>(_ a: A) -> ((A) -> B) -> B {
    { f in f(a) }
}

@inlinable
@inline(__always)
func ap<A, B>(_ f: @escaping (A) -> B) -> (A) -> B {
    { a in f(a) }
}

@inlinable
@inline(__always)
func tap<A>(_ a: A) -> ((A) -> ()) -> A {
    { f in tap(a, f) }
}

@inlinable
@inline(__always)
@discardableResult
func tap<A>(_ a: A, _ f: (A) -> ()) -> A {
    const(a)(f(a))
}

@inlinable
@inline(__always)
func first<A, B>(ab: (A, B)) -> A {
    ab.0
}

@inlinable
@inline(__always)
func second<A, B>(ab: (A, B)) -> B {
    ab.1
}

@inlinable
@inline(__always)
func eq<A: Equatable>(_ a: A) -> (A) -> Bool {
    { b in a == b }
}

@inlinable
@inline(__always)
func noteq<A: Equatable>(_ a: A) -> (A) -> Bool {
    { b in a != b }
}

// MARK: -

extension Optional {
    func tap(_ f: (Wrapped) -> ()) -> Self {
        const(self)(map(f))
    }

    func orElse(_ alt: () -> Self) -> Self {
        self ?? alt()
    }
}

// MARK: -

extension Sequence {
    func findMap<T>(_ f: (Element) -> T?) -> T? {
        for e in self {
            if let match = f(e) {
                return match
            }
        }

        return .none
    }
}
