import XCTest
@testable import RollbarCrashReport

final class ParserTests: XCTestCase {
    func testTemperature() {
        tap(Parser.int.skip("°F").parse("100°F")) {
            XCTAssertEqual($0.match, 100)
            XCTAssertEqual($0.rest, "")
        }
    }

    func testCoordinates() {
        tap(coord.parse("40.446° N, 79.982° W")) {
            XCTAssertEqual($0.match?.latitude, 40.446)
            XCTAssertEqual($0.match?.longitude, -79.982)
            XCTAssertEqual($0.rest, "")
        }
    }

    func testCurrency() {
        tap(money.parse("€100")) {
            XCTAssertEqual($0.match?.currency, .eur)
            XCTAssertEqual($0.match?.value, 100)
            XCTAssertEqual($0.rest, "")
        }

        tap(money.parse("£100")) {
            XCTAssertEqual($0.match?.currency, .gbp)
            XCTAssertEqual($0.match?.value, 100)
            XCTAssertEqual($0.rest, "")
        }

        tap(money.parse("$100")) {
            XCTAssertEqual($0.match?.currency, .usd)
            XCTAssertEqual($0.match?.value, 100)
            XCTAssertEqual($0.rest, "")
        }
    }

    func testUpcomingRaces() {
        struct Race {
            let loc: String
            let fee: Money
            let path: [Coordinate]
        }

        let locationName = Parser.prefix(while: { $0 != "," })
        let race = locationName
            .map(String.init)
            .skip(",")
            .skip(.prefix(" ").many())
            .take(money)
            .skip("\n")
            .take(coord.many(sep: "\n"))
        let races = race.many(sep: "\n---\n")

        tap(races.parse(upcomingRaces[...])) { (match: [(String, Money, [Coordinate])]?, rest: Substring) in
            guard let matches = match else {
                return XCTFail()
            }
            XCTAssertEqual(rest, "")
            XCTAssertEqual(matches.count, upcomingRacesParsed.count)
            zip(matches, upcomingRacesParsed).forEach { a, b in
                XCTAssertEqual(a.0, b.0)
                XCTAssertEqual(a.1, b.1)
                XCTAssertEqual(a.2, b.2)
            }
        }
    }

    func testLogs() {
        let testCaseFinished = Parser
            .skip(.prefix(through: " ("))
            .take(.double)
            .skip(" seconds).\n")

        let testCaseStarted = Parser
            .skip(.prefix(upTo: "Test Case '-["))
            .take(.prefix(through: "\n"))
            .map { $0.split(separator: " ")[3].dropLast(2) }

        let filename = Parser
            .skip("/")
            .take(.prefix(through: ".swift"))
            .bind { $0.split(separator: "/").last.map(Parser.always) ?? .never }

        tap(filename.parse("""
        /Users/point-free/projects/swift-composable-architecture/Examples/VoiceMemos/VoiceMemosTests/VoiceMemosTests.swift:107: error: -[VoiceMemosTests.VoiceMemosTests testPermissionDenied] : XCTAssertTrue failed
        """)) { (match: Substring?, rest: Substring) in
            guard let match = match else {
                return XCTFail()
            }
            XCTAssertEqual(rest, ":107: error: -[VoiceMemosTests.VoiceMemosTests testPermissionDenied] : XCTAssertTrue failed")
            XCTAssertEqual(match, "VoiceMemosTests.swift")
        }

        let testCaseBody = filename
            .skip(":")
            .take(.int)
            .skip(.prefix(through: "] : "))
            .take(.prefix(upTo: "Test Case '-[").map { $0.dropLast() })

        tap(testCaseBody.parse("""
        /Users/point-free/projects/swift-composable-architecture/Examples/VoiceMemos/VoiceMemosTests/VoiceMemosTests.swift:107: error: -[VoiceMemosTests.VoiceMemosTests testPermissionDenied] : XCTAssertTrue failed
        Test Case '-[VoiceMemosTests.VoiceMemosTests testPermissionDenied]' failed (0.003 seconds).
        """)) { (match: (Substring, Int, Substring)?, rest: Substring) in
            guard let match = match else {
                return XCTFail()
            }
            XCTAssertEqual(rest, "Test Case '-[VoiceMemosTests.VoiceMemosTests testPermissionDenied]' failed (0.003 seconds).")
            XCTAssertEqual(match.0, "VoiceMemosTests.swift")
            XCTAssertEqual(match.1, 107)
            XCTAssertEqual(match.2, "XCTAssertTrue failed")
        }

        let testFailed = testCaseStarted
            .take(testCaseBody)
            .take(testCaseFinished)
            .map(TestResult.failed)

        let testPassed = testCaseStarted
            .take(testCaseFinished)
            .map(TestResult.passed)

        let testResult = Parser.oneOf(testFailed, testPassed)
        let testResults = testResult.many()

        tap(testResults.parse(logs[...])) { (match: [TestResult]?, rest: Substring) in
            guard let matches = match else {
                return XCTFail()
            }
            XCTAssertEqual(rest, "Test Suite \'VoiceMemosTests\' failed at 2020-08-19 12:36:12.094.\nExecuted 8 tests, with 3 failures (0 unexpected) in 0.029 (0.032) seconds\nTest Suite \'VoiceMemosTests.xctest\' failed at 2020-08-19 12:36:12.094.\nExecuted 8 tests, with 3 failures (0 unexpected) in 0.029 (0.032) seconds\nTest Suite \'All tests\' failed at 2020-08-19 12:36:12.095.\nExecuted 8 tests, with 3 failures (0 unexpected) in 0.029 (0.033) seconds\n2020-08-19 12:36:19.538 xcodebuild[45126:3958202] [MT] IDETestOperationsObserverDebug: 14.165 elapsed -- Testing started completed.\n2020-08-19 12:36:19.538 xcodebuild[45126:3958202] [MT] IDETestOperationsObserverDebug: 0.000 sec, +0.000 sec -- start\n2020-08-19 12:36:19.538 xcodebuild[45126:3958202] [MT] IDETestOperationsObserverDebug: 14.165 sec, +14.165 sec -- end\nTest session results, code coverage, and logs:\n/Users/point-free/Library/Developer/Xcode/DerivedData/ComposableArchitecture-fnpkwoynrpjrkrfemkkhfdzooaes/Logs/Test/Test-VoiceMemos-2020.08.19_12-35-57--0400.xcresult\nFailing tests:\nVoiceMemosTests:\n    VoiceMemosTests.testPermissionDenied()\n    VoiceMemosTests.testRecordMemoFailure()\n    VoiceMemosTests.testRecordMemoHappyPath()")
            XCTAssertEqual(matches, logsParsed)
        }
    }

    func testCollection() {
        tap(Parser.prefix([1, 2]).parse([1, 2, 3, 4, 5][...])) {
            guard let _ = $0.match else { return XCTFail() }
            XCTAssertEqual($0.rest, [3, 4, 5])
        }
    }

    static var allTests = [
        ("testTemperature", testTemperature),
        ("testCoordinates", testCoordinates),
        ("testCurrency", testCurrency),
        ("testUpcomingRaces", testUpcomingRaces),
        ("testLogs", testLogs),
        ("testCollection", testCollection),
    ]
}
