/// Represents a frame in the memory stack.
enum Frame: RawRepresentable {

    /// A structure holding a symbolicated stacktrace frame.
    struct Symbolicated {
        let instructionAddr: Address
        let object: (name: String, addr: Address)
        let symbol: (name: String, addr: Address)
    }

    /// A structure holding an unsymbolicated stacktrace frame.
    struct Unsymbolicated {
        let instructionAddr: Address
        let object: (name: String, addr: Address)
        let symbolAddr: Address
    }

    /// A stacktrace frame with only the instruction address in memory.
    case instruction(Address)
    /// A symbolicated frame in the memory stack (sans filename and line)
    case symbolicated(Symbolicated)
    /// An unsymbolicated frame in the memory stack.
    case unsymbolicated(Unsymbolicated)

    /// Returns a dictinoary representation of this frame.
    var rawValue: Report.Map {
        switch self {
        case let .instruction(addr):
            return [
                "instruction_addr": addr.value
            ]
        case let .unsymbolicated(frame):
            return [
                "instruction_addr": frame.instructionAddr.value,
                "object_name": frame.object.name,
                "object_addr": frame.object.addr.value,
                "symbol_addr": frame.symbolAddr.value
            ]
        case let .symbolicated(frame):
            return [
                "instruction_addr": frame.instructionAddr.value,
                "object_name": frame.object.name,
                "object_addr": frame.object.addr.value,
                "symbol_name": frame.symbol.name,
                "symbol_addr": frame.symbol.addr.value
            ]
        }
    }

    /// Returns a new instance of a frame in the memory stack from the given dictionary.
    init(rawValue frame: Report.Map) {
        let instructionAddr = Address.memory(frame[any: "instruction_addr", default: 0])
        let objectName = frame[String.self, "object_name"]
        let symbolName = frame[String.self, "symbol_name"]

        guard
            let objectAddr = frame[any: "object_addr"].map(Address.binary),
            let symbolAddr = frame[any: "symbol_addr"].map(Address.binary)
        else {
            self = .instruction(instructionAddr)
            return
        }

        switch (objectName, symbolName) {
        case let (objectName?, symbolName?) where symbolName != "<redacted>":
            self = .symbolicated(.init(
                instructionAddr: instructionAddr,
                object: (name: objectName, addr: objectAddr),
                symbol: (name: symbolName, addr: symbolAddr)))
        case _:
            self = .unsymbolicated(.init(
                instructionAddr: instructionAddr,
                object: (name: objectName ?? "?", addr: objectAddr),
                symbolAddr: symbolAddr))
        }
    }
}
