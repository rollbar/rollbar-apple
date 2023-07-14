import Foundation
import RollbarCrash

/// A `RollbarCrash` filter that produces a proper Apple crash report with rich diagnostic
/// information by parsing data from a raw crash hashmap.
///
/// `RollbarCrash` filters receive a set of reports, possibly transforms them, and then
/// calls a completion method.
@objcMembers
public class RollbarCrashFormattingFilter: NSObject, RollbarCrashReportFilter {

    /// This is the filter entry point.
    ///
    /// Since this is called from Obj-C, type information is poor, which is why the set of
    /// reports sent is `[Any]?`. Reports are reified as part of the validation process.
    ///
    /// `RollbarCrashReportFilterCompletion` is an ObjC function with three parameters:
    ///   - An array of `Dictionary<AnyHashable, Any>`, which are "filtered" reports.
    ///   - A boolean value stating whether all the reports were able to be processed.
    ///   - An `NSError` object with error information, or `nil` if no error.
    public func filterReports(
        _ reports: [Any]?,
        onCompletion complete: RollbarCrashReportFilterCompletion?
    ) -> () {
        let formattedResults = (reports ?? []).map { report in
            validated(report).map(format)
        }

        complete?(
            /*reports:*/formattedResults.compactMap(\.success?.string).map(NSString.init),
            /*didFinish:*/formattedResults.allSatisfy(\.isSuccess),
            /*error:*/formattedResults.first(where: \.isFailure)?.failure)
    }

    /// Returns the report if valid, otherwise an error specifying why
    /// validation failed.
    private func validated(_ report: Any) -> Result<Report, NSError> {
        guard let report = report as? Report else {
            return .failure(.invalidType(report))
        }

        guard report.reportVersion.hasPrefix("3.") else {
            return .failure(.unsupported(report, version: report.reportVersion))
        }

        let missingKeys = Report.requiredKeys.filter(!report.keys.contains)

        guard missingKeys.isEmpty else {
            return .failure(.missingKeys(report, keys: missingKeys))
        }

        return .success(report)
    }
}

// MARK: -

fileprivate extension RollbarCrashFormattingFilter {

    /// Returns a formatted string with the formatted crash report.
    func format(_ report: Report) -> Formatted<String> {
        .init {
            header(for: report, system: report.system)
            error(for: report)
            diagnostics(for: report, exception: report.exception)
            for thread in report.crash.threads {
                threadInfo(for: thread, process: report.system.processName)
            }
            if let crashedThread = report.crash.crashedThread {
                cpuState(for: crashedThread, cpu: report.system.cpu)
            }
            binaryImages(for: report)

            if let recrash = report.recrashReport {
                "\nHandler crashed while reporting:\n"
                error(for: recrash)
                if let process = recrash.report?.processName,
                   let recrashedThread = recrash.crash.crashedThread
                {
                    threadInfo(for: recrashedThread, process: process)
                    cpuState(for: recrashedThread, cpu: report.system.cpu)
                }
                "\nRecrash Diagnosis: " *? recrash.crash.diagnosis
            }
        }
    }

    /// Formats the header section of the crash report.
    ///
    /// Some lines may be missing depending on the information available,
    /// for more info, see the [micro-DSL](x-source-tag://DSL) used to format
    /// reports.
    ///
    /// Example:
    /// ```
    /// Incident Identifier: 74C597A4-8AFD-4611-8C25-1547E4FD8E8C
    /// CrashReporter Key:   33f6cae3f5d192f79bd3a18c8bac24d6ef24b08b
    /// Hardware Model:      iPhone12,5
    /// Process:             iosAppSwift [11466]
    /// Path:                /private/var/containers/Bundle/Application/88931A2D-AF88-4252-97C6-677C0915BFB0/iosAppSwift.app/iosAppSwift
    /// Identifier:          com.matux.test.rollbarAppDemo
    /// Version:             4 (1.0)
    /// Code Type:           ARM-64
    /// Parent Process:      ? [1]
    ///
    /// Date/Time:           2023-02-13 11:44:50.942 -0300
    /// OS Version:          iOS 16.3 (20D47)
    /// Report Version:      104
    /// ```
    func header(for report: Report, system: Report.Map) -> Formatted<String> {
        .init {
            "Incident Identifier: " *? report.reportId.uuidString
            "CrashReporter Key:   " *? system.deviceAppHash
            "Hardware Model:      " *? system.machine
            "Process:             " *? system.processName *? " [" *? system.processId *? "]"
            "Path:                " *? system.bundleExecutablePath?.absoluteString
            "Identifier:          " *? system.bundleIdentifier
            "Version:             " *? system.bundleVersion *? " (" *? system.bundleShortVersion *? ")"
            "Code Type:           " *? system.cpu.typeName
            "Parent Process:      " *? system.parentProcessName *? " [" *? system.parentProcessId *? "]"
            ""
            "Date/Time:           " *? report.reportTimestamp?.iso8601String
            "OS Version:          " *? system.systemName *? " " *? system.systemVersion *? " (" *? system.osVersion *? ")"
            "Report Version:      104"
        }
    }

    /// Formats the error section of the crash report.
    ///
    /// Example:
    /// ```
    /// Exception Type:     EXC_CRASH (SIGABRT)
    /// Exception Subtype:  0x00000000 at 0x00000001b054a0cc
    /// Exception Codes:    0x0000000000000000, 0x0000000000000000
    /// Termination Reason: SIGNAL 6
    /// ```
    func error(for report: Report) -> Formatted<String> {
        let error = report.crash.error
        let (mach, signal) = (error?.mach, error?.signal)

        return .init {
            "\nException Type:     " *? mach?.exceptionName *? " (" *? signal?.signalName *? ")"
            "Exception Subtype:  " *? mach?.codeName *? " at " *? error?.address
            "Exception Codes:    " *? mach?.code *? ", " *? mach?.subcode
            "Termination Reason: SIGNAL " *? signal?.signalCode
            "\nTriggered by Thread:  " *? report.crashedThread?.index
        }
    }

    /// Formats the application specific information section of the crash report.
    ///
    /// Some lines may be missing depending on the information available.
    ///
    /// Example:
    /// ```
    /// Application Specific Information:
    ///
    /// Rollbar Diagnosis: Fatal error: Can't unsafeBitCast between types of different sizes (Swift/arm64-apple-ios-simulator.swiftinterface:3112)
    ///
    /// Rollbar Full Diagnostics:
    /// {
    ///     "source" : "libswiftCore.dylib",
    ///     "diagnosis" : "Fatal error: Can't unsafeBitCast between types of different sizes (Swift\/arm64-apple-ios-simulator.swiftinterface:3112)"
    /// }
    /// {
    ///     ...
    /// }
    ///
    /// Application Stats:
    /// {
    ///     "active_time_since_last_crash" : 9.7142499999999998,
    ///     "launches_since_last_crash" : 3,
    ///     ...
    /// }
    /// ```
    func diagnostics(for report: Report, exception: Report.Map?) -> Formatted<String> {
        .init {
            "\nApplication Specific Information:"
            "*** Terminating app due to uncaught exception '" *? exception?.name *? "' , reason: '" *? exception?.reason *? "'"

            if report.exceptionType == .zombie {
                "NOTE: This exception has been deallocated!"
                "      Stack trace is from a crash while attempting to access this zombie exception."
            }

            if let referencedObject = exception?.referencedObject {
                "Object Referenced by NSException:"
                referencedObject
            }

            if let exception = exception, report.exceptionType == .user {
                "Custom backtrace:"
                "Line: " *? exception.lineOfCode
                exception.userBacktrace
            }

            "Rollbar Diagnosis: " *? report.crash.diagnosis

            if report.crashType == .deadlock {
                "\nApplication main thread deadlocked."
            }

            "\nRollbar Full Diagnostics:"
            report.crash.diagnostics

            if let crashedThread = report.crashedThread, let stack = crashedThread.stack {
                "\nStack Dump (" *? stack.dumpStart *? "-" *? stack.dumpEnd *? ")"
                "\n" *? stack.contents
                "\nNotable Addresses:\n" *? crashedThread.notableAddresses
            }

            if let e = report.process?.lastDeallocedNSException {
                "\nLast deallocated NSException (" *? e.address *? "): " *? e.name *? ": " *? e.reason
                "Referenced object:\n" *? e.referencedObject
                backtrace(for: e.backtraceContents, process: report.system.processName)
            }

            if let stats = report.system.appStats {
                "\nApplication Stats:"
                "{"
                for stat in stats.sorted(by: their(\.key)) {
                    "\t\(stat.key): \(stat.value)"
                }
                "}"
            }
        }
    }

    /// Formats a thread together with its stack trace.
    ///
    /// Example:
    /// ```
    /// Thread 3 name:  com.apple.uikit.eventfetch-thread
    /// Thread 3:
    /// 0   libsystem_kernel.dylib          0x00000001b05422ac mach_msg2_trap + 8
    /// ...
    /// 11  libsystem_pthread.dylib         0x00000001b059e4e4 _pthread_start + 116
    /// ```
    func threadInfo(for thread: Report.Map, process: String) -> Formatted<String> {
        .init {
            ""
            "Thread \(thread.index)" *? " name:  " *? thread.threadName
            "Thread \(thread.index)\(thread.crashed ? " Crashed:" : ":")"
            backtrace(for: thread.backtraceContents, process: process)
        }
    }

    /// Formats a backtrace.
    ///
    /// Example:
    /// ```
    /// 0   libsystem_kernel.dylib          0x00000001b05422ac mach_msg2_trap + 8
    /// ...
    /// 11  libsystem_pthread.dylib         0x00000001b059e4e4 _pthread_start + 116
    /// ```
    func backtrace(for backtrace: [Frame], process: String) -> Formatted<String> {
        .init {
            for (n, frame) in backtrace.enumerated() {
                let index = "\(n)".pad(3)

                switch frame {
                case let .instruction(addr):
                    "\(index) \("?".pad(31)) \(addr) ? + \(addr.value)"

                case let .symbolicated(frame) where frame.object.name == process:
                    let preamble = "\(index) \(frame.object.name.pad(31)) \(frame.instructionAddr)"
                    let offset = frame.instructionAddr - frame.object.addr.value
                    "\(preamble) \(frame.object.addr) + \(offset.value)"

                case let .symbolicated(frame):
                    let preamble = "\(index) \(frame.object.name.pad(31)) \(frame.instructionAddr)"
                    let offset = frame.instructionAddr - frame.symbol.addr.value
                    "\(preamble) \(frame.symbol.name) + \(offset.value)"

                case let .unsymbolicated(frame):
                    let preamble = "\(index) \(frame.object.name.pad(31)) \(frame.instructionAddr)"
                    let offset = frame.instructionAddr - frame.object.addr.value
                    "\(preamble) \(frame.object.addr) + \(offset.value)"
                }
            }
        }
    }

    /// Formats a thread's registers.
    ///
    /// Example:
    /// ```
    /// Thread 0 crashed with ARM Thread State (64-bit):
    ///     x0: 0x0000000282f40060   x1: 0x0000000000000000   x2: 0xffffffffffffffe0   x3: 0x0000000282f40060
    ///     x4: 0x0000000282f400c0   x5: 0x000000016f048b60   x6: 0x0000000000000065   x7: 0x0000000000000001
    ///     x8: 0x00000000000000cc   x9: 0x00000000000000cb  x10: 0x0000000000000050  x11: 0x00000000000007fb
    ///    x12: 0x000000008b064ffb  x13: 0x00000000000007fd  x14: 0x000000008b265002  x15: 0x000000008b064ffb
    ///    x16: 0x0000000000000002  x17: 0x000000000b200000  x18: 0x0000000000000000  x19: 0x0000000104532288
    ///    x20: 0x0000000280c7ac40  x21: 0x000000028274d980  x22: 0x0000000104532240  x23: 0x0000000104531aa8
    ///    x24: 0x0000000280258810  x25: 0x00000001959bb91c  x26: 0x0000000280c56600  x27: 0x0000000000000002
    ///    x28: 0x0000000280e44070   fp: 0x000000016f048c10   lr: 0x4e2ebf818b87eac4
    ///     sp: 0x000000016f048bf0   pc: 0x000000018b87eac4 cpsr: 0x60000000
    ///    far: 0x000000016b2dfff0  esr: 0xf2000001 (Breakpoint) brk 1
    /// ```
    func cpuState(for thread: Report.Map, cpu: CPU) -> Formatted<String> {
        .init {
            "\nThread \(thread.index) crashed with \(cpu.typeName) Thread State:"

            for chunk in cpu.registers.chunks(of: 4) {
                chunk.map { "\($0.pad(-6)): " *? thread.registersState[$0] }
                    .compact().joined(separator: " ")
            }
        }
    }

    /// Formats the binary images section of a crash report.
    ///
    /// ```
    /// Binary Images:
    /// 0x0104fa8000 - 0x01050c3fff +iosAppSwift arm64  <cee0da5f0205374c9f8b7d6eda58dc42> /Users/matux/Library/Developer/CoreSimulator/Devices/D0A3BA18-8B19-43A4-9B7D-FFB0577EE2B9/data/Containers/Bundle/Application/0CC38EA0-F306-4C14-8157-14057B20075F/iosAppSwift.app/iosAppSwift
    /// 0x0105330000 - 0x0105333fff  libswiftWebKit.dylib arm64  <73bebae1764e32cbb78c34c92c0bd8d6> /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/usr/lib/swift/libswiftWebKit.dylib
    /// 0x0105348000 - 0x010534bfff  UIKit arm64  <8b15488095fe390fae821a3a3a640227> /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/Frameworks/UIKit.framework/UIKit
    /// ...
    /// 0x01b05ad000 - 0x01b05adfff  libsystem_sim_pthread_host.dylib arm64  <2544ef58c14d30b1a9fcce9d35e10cb0> /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/usr/lib/system/libsystem_sim_pthread_host.dylib
    /// ```
    func binaryImages(for report: Report) -> Formatted<String> {
        .init {
            "\nBinary Images:"
            for img in report.binaryImages.sorted(by: their(\.addr.start)) {
                let cpu = img.cpu.subtypeName
                let uuid = img.uuid.uuidString.replacingOccurrences(of: "-", with: "").lowercased()
                let isMain = img.path == report.system.bundleExecutablePath ? "+" : " "
                "\(img.addr.start) - \(img.addr.end) \(isMain)\(img.name) \(cpu)  <\(uuid)> \(img.path.absoluteString)"
            }
        }
    }
}

fileprivate extension Report {

    static var requiredKeys = [
        "crash",
        "report",
        "system",
        "binary_images",
    ]
}
