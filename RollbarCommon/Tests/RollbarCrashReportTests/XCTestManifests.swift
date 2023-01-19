import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ParserTests.allTests),
        testCase(CrashReportTests.allTests),
    ]
}
#endif
