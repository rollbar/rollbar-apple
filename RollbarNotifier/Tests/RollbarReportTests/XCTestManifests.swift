#if !os(watchOS)
import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(RollbarCrashReportTests.allTests),
    ]
}
#endif
#endif
