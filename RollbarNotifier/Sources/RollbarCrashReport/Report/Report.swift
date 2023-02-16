import Darwin.POSIX
import Foundation

/// A `Report` is just a dictionary where its keys are a `String` and its values `Any`.
///
/// The typealias provides no type guarantees and its only purpose is to provide context at
/// the point of use.
@usableFromInline
typealias Report = [String: Any]

// MARK: - Report | root

/// Point of access for the `Report`. The main purpose is to provide type information to
/// the `Report` dictionary's contents.
extension Report {
    /// A `Map` is an alias for any nested dictionary within a `Report`.
    @usableFromInline
    typealias Map = [String: Any]

    enum CrashType: String {
        case mach, signal, deadlock, nsexception, unknown
    }

    enum ExceptionType {
        case ns, zombie, cpp, user
    }

    var error: Map? { self[any: "error"] }
    var system: Map { self[any: "system", default: [:]] }
    var process: Map? { self[any: "process"] }
    var recrashReport: Map? { self[any: "recrash_report"] }
    var binaryImages: [BinaryImage] {
        self[any: "binary_images", default: []].map(BinaryImage.init)
    }

    var crash: Map {
        get { self[any: "crash", default: [:]] }
        set { self["crash"] = newValue }
    }

    var report: Map? { self[any: "report"] }
    var reportId: UUID { self[any: "report.id"].flatMap(UUID.init) ?? .empty }
    var reportTimestamp: Timestamp? { self[any: "report.timestamp"].flatMap(Timestamp.init) }
    var reportVersion: String { self[any: "report.version", default: "unknown"] }

    var name: String? { self[any: "name"] }
    var uuid: UUID { self[any: "uuid"].flatMap(UUID.init) ?? .empty }

    var index: Int {
        self[any: "index", default: -1]
    }

    var crashType: CrashType {
        self.crash.error?[any: "type"].flatMap(CrashType.init) ?? .unknown
    }

    var exception: Map? {
        self[any: "crash.error.nsexception"]
        ?? self[any: "process.last_dealloced_nsexception"]
        ?? self[any: "crash.error.cpp_exception"]
        ?? self[any: "crash.error.user_reported"]
    }

    var exceptionType: ExceptionType? {
        guard let error = self.crash.error?.keys else {
            return .none
        }

        if error.contains("nsexception") { return .ns }
        else if self.isZombieNSException { return .zombie }
        else if error.contains("cpp_exception") { return .cpp }
        else if error.contains("user_reported") { return .user }
        else { return .none }
    }
}

// MARK: - System | root.system

extension Report {

    var appStats: Map? { self[any: "application_stats"] }

    var bundleIdentifier: String? { self[any: "CFBundleIdentifier"] }
    var bundleVersion: String? { self[any: "CFBundleVersion"] }
    var bundleShortVersion: String? { self[any: "CFBundleShortVersionString"] }
    var bundleExecutablePath: URL? { self[any: "CFBundleExecutablePath"].flatMap(URL.init) }

    var processName: String { self[any: "process_name", default: "unknown"] }
    var processId: Int? { self[any: "process_id"] }
    var parentProcessName: String { self[any: "parent_process_name", default: "?"] }
    var parentProcessId: Int? { self[any: "parent_process_id"] }

    var deviceAppHash: String? { self[any: "device_app_hash"] }
    var systemName: String? { self[any: "system_name"] }
    var systemVersion: String? { self[any: "system_version"] }
    var osVersion: String? { self[any: "os_version"] }
    var machine: String? { self[any: "machine"] }

    var cpu: CPU {
        .init(
            type: self[any: "binary_cpu_type"] ?? self[any: "cpu_type"] ?? CPU_TYPE_ANY,
            subtype: self[any: "binary_cpu_subtype"] ?? self[any: "cpu_subtype"] ?? CPU_SUBTYPE_ANY)
    }
}

// MARK: - Crash | root.crash

extension Report {

    var diagnosis: String? {
        get { self[any: "diagnosis"] }
        set { self["diagnosis"] = newValue }
    }

    var diagnostics: [Diagnostic] {
        get { self[any: "diagnostics", default: []].compactMap(Diagnostic.init) }
        set { self["diagnostics"] = newValue.map(\.rawValue) }
    }

    var crashedThread: Map? {
        self.crash.threads.first(where: \.crashed)
        ?? self[any: "crashed_thread"]
    }
}

// MARK: - Error | root.crash.error

extension Report {

    var address: Address? { self[any: "address"].map(Address.memory) }
    var mach: Map? { self[any: "mach"] }
    var signal: Map? { self[any: "signal"] }

    var exceptionName: String { self[any: "exception_name", default: "0"] }
    var codeName: String { self[any: "code_name", default: "0x00000000"] }
    var signalName: String { self[any: "name", default: self[any: "signal"] ?? "?"] }
    var signalCode: Int? { self[any: "signal"] }
    var code: Address? { self[any: "code"].map(Address.memory) }
    var subcode: Address? { self[any: "subcode"].map(Address.memory) }
}

// MARK: - Exception | root.crash.error.exception

extension Report {

    var lastDeallocedNSException: Map? { self[any: "last_dealloced_nsexception"] }
    var referencedObject: Map? { self[any: "referenced_object"] }

    var reason: String? { self[any: "reason"] }
    var lineOfCode: String? { self[any: "line_of_code"] }
}

// MARK: - Threads | root.crash.error.threads[n]

extension Report {

    var threads: [Map] {
        self[any: "threads", default: []]
    }

    var crashed: Bool {
        self[any: "crashed", default: false]
    }

    var threadName: String? {
        switch (self.name, self.dispatchQueue) {
        case (.some(let name), _): return name
        case (_, .some(let name)): return "Dispatch queue: \(name)"
        case _: return .none
        }
    }

    var dispatchQueue: String? {
        self[any: "dispatch_queue"]
    }

    var registersState: [AnyHashable: Address] {
        self[Map.self, "registers.basic", default: [:]].mapValues {
            .memory($0 as? UInt ?? 0)
        }
    }

    var stack: Map? { self[any: "stack"]}
    var contents: String? { self[any: "contents"] }
    var notableAddresses: Map? { self[any: "notable_addresses"] }
    var dumpStart: Address? { self[any: "dump_start"].map(Address.memory) }
    var dumpEnd: Address? { self[any: "dump_end"].map(Address.memory) }

    var userBacktrace: [String]? { self[any: "backtrace"] }
    var backtraceContents: [Frame] {
        self[any: "backtrace.contents", default: []].map(Frame.init)
    }
}

// MARK: -

extension Report {

    fileprivate var isZombieNSException: Bool {
        let mach = self.crash.error?.mach

        guard
            mach?.exceptionName == "EXC_BAD_ACCESS" && mach?.codeName == "KERN_INVALID_ADDRESS",
            let address = self.process?.lastDeallocedNSException?.address,
            let crashedThread = self.crash.threads.first(where: \.crashed)
        else {
            return false
        }

        return crashedThread.registersState.values.contains(address)
    }
}

extension Dictionary where Key == String, Value: Any {

    @usableFromInline
    var description: String {
        Data(from: self, options: .prettyPrinted)
            .flatMap { String(data: $0, encoding: .utf8) }
        ?? "Could not describe Dictionary instance."
    }
}
