#if !os(watchOS)
import XCTest
@testable import RollbarCrashReport

final class RollbarCrashReportTests: XCTestCase {

    func testRollbarCrashReportDiagnostics() {
        let report = Bundle.module
            .url(forResource: "crash.json", withExtension: .none)
            .flatMap { try? Data(contentsOf: $0) }
            .flatMap { try? JSONSerialization.jsonObject(with: $0) }

        XCTAssertNotNil(report)

        RollbarCrashDiagnosticFilter().filterReports([report!]) { reports, didComplete, error in
            XCTAssertTrue(didComplete)
            XCTAssertNil(error)
            XCTAssertNotNil(reports)
            XCTAssertNotNil(reports?.first)
            XCTAssertNotNil(reports?.first as? Report.Map)
            XCTAssertEqual(reports?.count, 1)

            guard let report = reports?.first as? Report.Map else {
                return XCTFail()
            }

            XCTAssertEqual(report.crash.diagnosis, "Fatal error: Unexpectedly found nil while unwrapping an Optional value (iosAppSwift/ContentView.swift:117)")
            XCTAssertEqual(report.crash.diagnostics.count, 3)
            XCTAssertEqual(report.crash.diagnostics[0][any: "source"], "libswiftCore.dylib")
            XCTAssertEqual(report.crash.diagnostics[1][any: "source"], "Exception Type")
            XCTAssertEqual(report.crash.diagnostics[2][any: "source"], "Exception Codes")
            XCTAssertEqual(report.crash.diagnostics[0][any: "diagnosis"], "Fatal error: Unexpectedly found nil while unwrapping an Optional value (iosAppSwift/ContentView.swift:117)")
            XCTAssertEqual(report.crash.diagnostics[1][any: "diagnosis"], "EXC_BREAKPOINT (SIGTRAP)")
            XCTAssertEqual(report.crash.diagnostics[2][any: "diagnosis"], "KERN_INVALID_ADDRESS at 0x18b87eac4")
        }
    }
}

#endif
