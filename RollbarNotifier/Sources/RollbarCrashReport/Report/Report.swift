import Darwin.POSIX
import Foundation

/// A `Report` is just a dictionary where its keys are a `String` and its values `Any`.
///
/// The typealias provides no type guarantees and its only purpose is to provide context at
/// the point of use.
typealias Report = [String: Any]

/// Point of access for the `Report`. The main purpose is to provide type information to
/// the `Report` dictionary's contents.
extension Report {
    /// A `Map` is an alias for any nested dictionary within a `Report`.
    typealias Map = [String: Any]

    var error: Map? { self[any: "error"] }
    var crash: Map {
        get { self[any: "crash", default: [:]] }
        set { self["crash"] = newValue }
    }

    var binaryImages: [Map] { self[any: "binary_images", default: []] }

    var crashInfoMessages: [String] {
        ["crash_info_message", "crash_info_message2"]
            .compactMap { self[$0] as? String }
    }

    var hasCrashInfoMessage: Bool {
        ["crash_info_message", "crash_info_message2"]
            .contains(where: keys.contains)
    }

    var diagnosis: String? {
        get { self[any: "diagnosis"] }
        set { self["diagnosis"] = newValue }
    }

    var diagnostics: [Map] {
        get { self[any: "diagnostics", default: []] }
        set { self["diagnostics"] = newValue }
    }

    var fileName: String {
        self.name.flatMap { URL(string: $0)?.lastPathComponent } ?? "unknown"
    }

    var address: String {
        (self["address"] as? uintptr_t).map { "0x\(String($0, radix: 16))" }
            ?? "0x00000000"
    }

    var name: String? { self[any: "name"] }
    var type: String? { self[any: "type"] }

    var mach: Map? { self[any: "mach"] }
    var signal: Map? { self[any: "signal"] }

    var exceptionName: String { self[any: "exception_name", default: "0"] }
    var codeName: String { self[any: "code_name", default: "0x00000000"] }
    var signalName: String { self[any: "name", default: self[any: "signal"] ?? "?"] }
}
