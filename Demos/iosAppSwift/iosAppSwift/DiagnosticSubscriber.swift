#if os(iOS) || os(macOS) && canImport(MetricKit)

import RollbarSwift
import RollbarNotifier
import MetricKit

@available(iOS 15.0, macOS 12.0, macCatalyst 15.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@objcMembers
class DiagnosticSubscriber: NSObject, MXMetricManagerSubscriber {
    static let shared = DiagnosticSubscriber()

    override private init() {}

    static func start() {
        MXMetricManager.shared.add(shared)
    }

    static func stop() {
        MXMetricManager.shared.remove(shared)
    }

    func didReceive(_ payloads: [MXDiagnosticPayload]) {
        payloads.forEach { p in
            p.cpuExceptionDiagnostics?.forEach(notify)
            p.diskWriteExceptionDiagnostics?.forEach(notify)
            p.hangDiagnostics?.forEach(notify)
            p.crashDiagnostics?.forEach(notify)
        }
    }

    @nonobjc func notify(_ diagnostic: MXCPUExceptionDiagnostic) {
        print(diagnostic)
    }

    @nonobjc func notify(_ diagnostic: MXDiskWriteExceptionDiagnostic) {
        print(diagnostic)
    }

    @nonobjc func notify(_ diagnostic: MXHangDiagnostic) {
        print(diagnostic)
    }

    @nonobjc func notify(_ diagnostic: MXCrashDiagnostic) {
        let stackTree = diagnostic.callStackTree.jsonRepresentation()
        let reason = diagnostic.terminationReason
        let virtualMemoryRegionInfo = diagnostic.virtualMemoryRegionInfo
        let exceptionType = diagnostic.exceptionType
        let exceptionCode = diagnostic.exceptionCode
        let signal = diagnostic.signal

        // force unwrap:     exception 6  (1) signal 5
        // force cast:       exception 10 (0) signal 6
        // force try:        exception 6  (1) signal 5
        // out of bounds:    exception 6  (1) signal 5
        // div by 0:         exception 6  (1) signal 5
        // assertionFailure: exception 6  (1) signal 5
        // precondFailure:   exception 6  (1) signal 5
        // fatalError:       exception 6  (1) signal 5




        debugPrint(diagnostic)
//        dump("reason: \(reason)")
//        print("exceptionType: \(exceptionType)")
//        print(exceptionCode)
//        print(signal)
//        print(virtualMemoryRegionInfo)
//        print(stackTree)
    }
}

extension MXCrashDiagnostic /*: CustomDebugStringConvertible*/ {
    override open var debugDescription: String {
        """
        \(self)
            reason: \(terminationReason ?? ".none")
            exception: \(exceptionType ?? 0) (\(exceptionCode ?? 0))
            signal: \(signal ?? 0)
            virtualMemoryRegionInfo: \(virtualMemoryRegionInfo ?? ".none")
            callStackTree: \(callStackTree.debugDescription)
        """
    }
}

extension MXCallStackTree /*: CustomDebugStringConvertible*/ {
    override open var debugDescription: String {
        String(data: jsonRepresentation(), encoding: .utf8) ?? ".none"
    }
}

#endif
