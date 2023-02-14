import XCTest

import RollbarNotifierTests

XCTMain([
    RollbarNotifierTests.allTests(),
    RollbarCrashReportTests.allTests(),
])
