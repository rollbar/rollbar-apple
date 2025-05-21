/// A computer address that points either at memory or a binary
@usableFromInline
enum Address {
    /// A memory address.
    case memory(UInt)

    /// An address in a binary file.
    case binary(UInt)

    /// The size of the address.
    ///
    /// Menory addresses are architecture dependant, while binary
    /// addresses are always 32bits large.
    @usableFromInline
    var size: Int {
        switch self {
        case .memory: return MemoryLayout<UInt>.size
        case .binary: return MemoryLayout<UInt32>.size
        }
    }

    /// The raw address value.
    @usableFromInline
    var value: UInt {
        switch self {
        case .memory(let address): return address
        case .binary(let address): return address
        }
    }
}

extension Address: CustomStringConvertible {

    @usableFromInline
    var description: String {
        "0x\(String(self.value, radix: 16).pad(self.size * -2, with: "0"))"
    }
}

extension Address {

    /// Performs addition over an Address and an unsigned integer primitive.
    @inlinable
    static func + (lhs: Self, rhs: UInt) -> Self? {
        switch lhs {
        case let .memory(lhs):
            let (result, overflow) = lhs.addingReportingOverflow(rhs)
            return overflow ? nil : .memory(result)
        case let .binary(lhs):
            let (result, overflow) = lhs.addingReportingOverflow(rhs)
            return overflow ? nil : .binary(result)
        }
    }

    /// Performs substraction over an Address and an unsigned integer primitive.
    @inlinable
    static func - (lhs: Self, rhs: UInt) -> Self? {
        switch lhs {
        case let .memory(lhs):
            let (result, overflow) = lhs.subtractingReportingOverflow(rhs)
            return overflow ? nil : .memory(result)
        case let .binary(lhs):
            let (result, overflow) = lhs.subtractingReportingOverflow(rhs)
            return overflow ? nil : .binary(result)
        }
    }
}

extension Address: Equatable, Comparable, Hashable, Codable {

    @inlinable
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.value < rhs.value
    }
}
