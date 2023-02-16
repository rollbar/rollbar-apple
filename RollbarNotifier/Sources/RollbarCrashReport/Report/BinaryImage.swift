import Darwin.POSIX
import Foundation

/// A binary file, usually a dynamic library, that was currently loaded during a crash.
struct BinaryImage: RawRepresentable {
    /// The file name of the binary.
    var name: String { self.path.lastPathComponent }

    /// The full absolute path to the binary.
    let path: URL

    /// A UUID identifier.
    let uuid: UUID

    /// The binary's version.
    let version: (major: Int, minor: Int, revision: Int)

    /// The architecture which the binary was compiled for.
    let cpu: CPU

    /// An optional list of diagnostic messages.
    ///
    /// This might be present if the crash originated within this binary,
    /// but most of the time, it's empty.
    let crashInfoMessages: [String]

    /// The size of the binary in bytes.
    let size: UInt

    /// A tuple holding the starting and ending address pointing to
    /// the location of the symbols within the debug information file (dSYM/DWARF).
    let addr: (Address, Address)

    /// The VM address where this binary was located in memory.
    let vmaddr: Address

    /// A dictionary representing this structure's raw data.
    let rawValue: Report.Map

    /// Returns a new instance of a `BinaryImage` data structure from the given dictionary.
    init(rawValue: Report.Map) {
        self.rawValue = rawValue

        self.path = rawValue[any: "name"].flatMap(URL.init) ?? URL(string: "/")!
        self.uuid = rawValue[any: "uuid"].flatMap(UUID.init) ?? .empty
        self.version = (
            major: rawValue[any: "major_version", default: 0],
            minor: rawValue[any: "minor_version", default: 0],
            revision: rawValue[any: "revision_version", default: 0])

        self.vmaddr = .memory(rawValue[any: "image_vmaddr", default: 0])
        self.size = rawValue[any: "image_size", default: 0]

        self.cpu = .init(
            type: rawValue[any: "cpu_type"] ?? CPU_TYPE_ANY,
            subtype: rawValue[any: "cpu_subtype"] ?? CPU_SUBTYPE_ANY)

        self.crashInfoMessages = ["crash_info_message", "crash_info_message2"]
            .compactMap { rawValue[any: $0] }

        let addr = Address.binary(rawValue[any: "image_addr", default: 0])
        self.addr = (addr, addr + self.size - 1)
    }
}
