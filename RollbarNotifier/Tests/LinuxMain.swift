import XCTest

import RollbarNotifierTests
import RollbarReportTests

XCTMain([
    RollbarNotifierTests.allTests(),
    RollbarReportTests.allTests(),
])
