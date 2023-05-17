#if canImport(KSCrash_Reporting_Filters)
import KSCrash_Reporting_Filters
#else
import KSCrash
#endif

/// A `KSCrash` filter that produces richer diagnostic information by extracting data from a raw
/// crash hashmap that's not usually made available in Apple crash reports.
///
/// `KSCrash` filters receive a set of reports, possibly transforms them, and then
/// calls a completion method.
@objcMembers
public class RollbarCrashDiagnosticFilter: NSObject, KSCrashReportFilter {

    /// This is the filter entry point.
    ///
    /// Since this is called from Obj-C, type information is poor, which is why the set of
    /// reports sent is `[Any]?`. Reports are reified as part of the validation process.
    ///
    /// `KSCrashReportFilterCompletion` is an ObjC function with three parameters:
    ///   - An array of `Dictionary<AnyHashable, Any>`, which are "filtered" reports.
    ///   - A boolean value stating whether all the reports were able to be processed.
    ///   - An `NSError` object with error information, or `nil` if no error.
    public func filterReports(
        _ reports: [Any]?,
        onCompletion complete: KSCrashReportFilterCompletion?
    ) {
        let diagnosedResults = (reports ?? []).map { report in
            validated(report).flatMap(diagnose)
        }

        complete?(
            /*reports:*/diagnosedResults.compactMap(\.success),
            /*didFinish:*/diagnosedResults.allSatisfy(\.isSuccess),
            /*error:*/diagnosedResults.first(where: \.isFailure)?.failure)
    }

    /// Returns a new `Report` instance by diagnosing the given `Report`.
    ///
    /// Diagnostics are extracted from three sources:
    ///
    /// - The original `KSCrash` diagnosis, this is usually available for most
    ///   Objective-C, C and C++ crashes.
    /// - Dynamically linked libraries: Certain libraries like the Swift
    ///   runtime, and Cocoa framework report specialized diagnostic information
    ///   that's very useful.
    ///   * As an exception, we avoid `libsystem_sim_platform.dylib` as it
    ///     only reports simulator versioning info.
    ///   * Diagnostics coming from the Swift runtime are sanitized.
    /// - Mach exception and signals: Low-level / OS diagnostics.
    ///
    /// The best possible diagnosis is stored in `report.crash.diagnosis`,
    /// and `report.crash?.diagnostics` will contain all the collected
    /// diagnoses together with the source where the diagnosis originated.
    ///
    /// - Parameter report: The `Report` to diagnose.
    /// - Returns: A new `Report` with the parsed diagnostic information.
    private func diagnose(_ report: Report) -> Result<Report, NSError> {
        let kscrashDiagnostics = report.crash.diagnosis?
            .split(separator: "\n")
            .map { Diagnostic($0, source: report.crashType) } ?? []

        let dyldDiagnostics = report.binaryImages
            .filter(!\.crashInfoMessages.isEmpty)
            .flatMap { binaryImage in
                binaryImage.crashInfoMessages.map { diagnosis in
                    Diagnostic(diagnosis, source: binaryImage.name)
                }
            }
            .map { diagnostic in
                diagnostic.source == "libswiftCore.dylib"
                    ? diagnostic.formatted(with: SwiftDiagnosisFormatter())
                    : diagnostic
            }

        let diagnostic = kscrashDiagnostics.first
            ?? dyldDiagnostics.first(where: { $0.source != "libsystem_sim_platform.dylib" })

        var diagnosedReport = report
        diagnosedReport.crash.diagnosis = diagnostic?.diagnosis
        diagnosedReport.crash.diagnostics = kscrashDiagnostics + dyldDiagnostics
        return .success(diagnosedReport)
    }

    /// Returns the report if valid, otherwise an error specifying why
    /// validation failed.
    private func validated(_ report: Any) -> Result<Report, NSError> {
        guard let report = report as? Report else {
            return .failure(.invalidType(report))
        }

        let missingKeys = Report.requiredKeys.filter(!report.keys.contains)

        guard missingKeys.isEmpty else {
            return .failure(.missingKeys(report, keys: missingKeys))
        }

        return .success(report)
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

class SwiftDiagnosisFormatter: Formatter {

    /// Reformats an original diagnosis string from Swift.
    ///
    /// The format simply reverses the order in which the file and diagnosis appear, eg:
    ///
    ///     src/Code.swift:123: Fatal error: An error occurred
    ///
    /// Becomes
    ///
    ///     Fatal error: An error occurred (src/Code.swift:123)
    override func string(for string: Any?) -> String? {
        guard let string = (string as? String)?.trimming(.newlines) else { return .none }
        var groups = #"(^[^\s]+):\s(.*)"#.matches(in: string)?.makeIterator()
        return zip(groups?.next(), groups?.next()).map { (file, message) in
            "\(message) (\(file.replacing(#"\/"#, with: "/")))"
        } ?? string
    }
}
