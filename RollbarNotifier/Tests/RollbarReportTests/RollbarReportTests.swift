#if !os(watchOS)
import XCTest
@testable import RollbarReport

final class RollbarReportTests: XCTestCase {

    func testRollbarReportDiagnostics() {
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

            XCTAssertEqual(report.crash.diagnosis, "Fatal error: Unexpectedly found nil while unwrapping an Optional value (RollbarDemo/ContentView.swift:117)")
            XCTAssertEqual(report.crash.diagnostics.count, 1)
            XCTAssertEqual(report.crash.diagnostics[0].source, "libswiftCore.dylib")
            XCTAssertEqual(report.crash.diagnostics[0].diagnosis, "Fatal error: Unexpectedly found nil while unwrapping an Optional value (RollbarDemo/ContentView.swift:117)")
        }
    }

    func testRollbarReportFormatting() {
        let diagnosedCrash = Bundle.module
            .url(forResource: "diagnosed.json", withExtension: .none)
            .flatMap { try! Data(contentsOf: $0) }
            .flatMap { try! JSONSerialization.jsonObject(with: $0) }

        let expectReport = Bundle.module
            .url(forResource: "report.crash", withExtension: .none)
            .flatMap { try! String(contentsOf: $0) }

        XCTAssertNotNil(diagnosedCrash)
        XCTAssertNotNil(expectReport)

        RollbarCrashFormattingFilter().filterReports([diagnosedCrash!]) { reports, didComplete, error in
            XCTAssertTrue(didComplete)
            XCTAssertNil(error)
            XCTAssertNotNil(reports)
            XCTAssertNotNil(reports?.first)
            XCTAssertNotNil(reports?.first as? String)
            XCTAssertEqual(reports?.count, 1)

            guard let report = reports?.first as? String, let expectReport else {
                return XCTFail()
            }

            let rs = report.split(separator: "\n")
            let ex = expectReport.split(separator: "\n")
            XCTAssertEqual(rs.count, ex.count)
            for line in zip(rs, ex) {
                XCTAssertEqual(line.0, line.1)
            }
        }
    }
}

#endif
