import XCTest
import RollbarCommonTests
import RollbarCrashReportTests

XCTMain([XCTestCaseEntry]()
    + RollbarCommonTests.allTests()
    + ParserTests.allTests()
    + CrashReportTests.allTests())
