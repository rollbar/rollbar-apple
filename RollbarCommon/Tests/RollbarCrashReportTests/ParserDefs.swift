import Foundation
@testable import RollbarCrashReport

enum Currency: Equatable { case eur, gbp, usd }

struct Money: Equatable {
    let currency: Currency
    let value: Double
}

let currency = Parser<Substring, Currency>.oneOf(
    Parser.prefix("€").map { .eur },
    Parser.prefix("£").map { .gbp },
    Parser.prefix("$").map { .usd }
)

let money = currency.zip(.double).map(Money.init)

struct Coordinate: Equatable {
    let latitude: Double
    let longitude: Double
}

let northSouth = Parser.char.bind {
    $0 == "N" ? .always(1.0)
    : $0 == "S" ? .always(-1)
    : .never
}

let eastWest = Parser.char.bind {
    $0 == "E" ? .always(1.0)
    : $0 == "W" ? .always(-1)
    : .never
}

let latitude = Parser
    .double
    .skip("° ")
    .take(northSouth)
    .map(*)

let longitude = Parser
    .double
    .skip("° ")
    .take(eastWest)
    .map(*)

let coord = latitude
    .skip(",")
    .skip(.prefix(" ").many())
    .take(longitude)
    .map(Coordinate.init)

let upcomingRaces = """
    New York City, $300
    40.60248° N, 74.06433° W
    40.61807° N, 74.02966° W
    40.64953° N, 74.00929° W
    40.67884° N, 73.98198° W
    40.69894° N, 73.95701° W
    40.72791° N, 73.95314° W
    40.74882° N, 73.94221° W
    40.75740° N, 73.95309° W
    40.76149° N, 73.96142° W
    40.77111° N, 73.95362° W
    40.80260° N, 73.93061° W
    40.80409° N, 73.92893° W
    40.81432° N, 73.93292° W
    40.80325° N, 73.94472° W
    40.77392° N, 73.96917° W
    40.77293° N, 73.97671° W
    ---
    Berlin, €100
    13.36015° N, 52.51516° E
    13.33999° N, 52.51381° E
    13.32539° N, 52.51797° E
    13.33696° N, 52.52507° E
    13.36454° N, 52.52278° E
    13.38152° N, 52.52295° E
    13.40072° N, 52.52969° E
    13.42555° N, 52.51508° E
    13.41858° N, 52.49862° E
    13.40929° N, 52.48882° E
    13.37968° N, 52.49247° E
    13.34898° N, 52.48942° E
    13.34103° N, 52.47626° E
    13.32851° N, 52.47122° E
    13.30852° N, 52.46797° E
    13.28742° N, 52.47214° E
    13.29091° N, 52.48270° E
    13.31084° N, 52.49275° E
    13.32052° N, 52.50190° E
    13.34577° N, 52.50134° E
    13.36903° N, 52.50701° E
    13.39155° N, 52.51046° E
    13.37256° N, 52.51598° E
    ---
    London, £500
    51.48205° N, 0.04283° E
    51.47439° N, 0.02170° E
    51.47618° N, 0.02199° E
    51.49295° N, 0.05658° E
    51.47542° N, 0.03019° E
    51.47537° N, 0.03015° E
    51.47435° N, 0.03733° E
    51.47954° N, 0.04866° E
    51.48604° N, 0.06293° E
    51.49314° N, 0.06104° E
    51.49248° N, 0.04740° E
    51.48888° N, 0.03564° E
    51.48655° N, 0.01830° E
    51.48085° N, 0.02223° W
    51.49210° N, 0.04510° W
    51.49324° N, 0.04699° W
    51.50959° N, 0.05491° W
    51.50961° N, 0.05390° W
    51.49950° N, 0.01356° W
    51.50898° N, 0.02341° W
    51.51069° N, 0.04225° W
    51.51056° N, 0.04353° W
    51.50946° N, 0.07810° W
    51.51121° N, 0.09786° W
    51.50964° N, 0.11870° W
    51.50273° N, 0.13850° W
    51.50095° N, 0.12411° W
    """

let upcomingRacesParsed: [(String, Money, [Coordinate])] = [
    ("New York City", Money(currency: .usd, value: 300), [
        Coordinate(latitude: 40.60248, longitude: -74.06433),
        Coordinate(latitude: 40.61807, longitude: -74.02966),
        Coordinate(latitude: 40.64953, longitude: -74.00929),
        Coordinate(latitude: 40.67884, longitude: -73.98198),
        Coordinate(latitude: 40.69894, longitude: -73.95701),
        Coordinate(latitude: 40.72791, longitude: -73.95314),
        Coordinate(latitude: 40.74882, longitude: -73.94221),
        Coordinate(latitude: 40.75740, longitude: -73.95309),
        Coordinate(latitude: 40.76149, longitude: -73.96142),
        Coordinate(latitude: 40.77111, longitude: -73.95362),
        Coordinate(latitude: 40.80260, longitude: -73.93061),
        Coordinate(latitude: 40.80409, longitude: -73.92893),
        Coordinate(latitude: 40.81432, longitude: -73.93292),
        Coordinate(latitude: 40.80325, longitude: -73.94472),
        Coordinate(latitude: 40.77392, longitude: -73.96917),
        Coordinate(latitude: 40.77293, longitude: -73.97671),
    ]),
    ("Berlin", Money(currency: .eur, value: 100), [
        Coordinate(latitude: 13.36015, longitude: 52.51516),
        Coordinate(latitude: 13.33999, longitude: 52.51381),
        Coordinate(latitude: 13.32539, longitude: 52.51797),
        Coordinate(latitude: 13.33696, longitude: 52.52507),
        Coordinate(latitude: 13.36454, longitude: 52.52278),
        Coordinate(latitude: 13.38152, longitude: 52.52295),
        Coordinate(latitude: 13.40072, longitude: 52.52969),
        Coordinate(latitude: 13.42555, longitude: 52.51508),
        Coordinate(latitude: 13.41858, longitude: 52.49862),
        Coordinate(latitude: 13.40929, longitude: 52.48882),
        Coordinate(latitude: 13.37968, longitude: 52.49247),
        Coordinate(latitude: 13.34898, longitude: 52.48942),
        Coordinate(latitude: 13.34103, longitude: 52.47626),
        Coordinate(latitude: 13.32851, longitude: 52.47122),
        Coordinate(latitude: 13.30852, longitude: 52.46797),
        Coordinate(latitude: 13.28742, longitude: 52.47214),
        Coordinate(latitude: 13.29091, longitude: 52.48270),
        Coordinate(latitude: 13.31084, longitude: 52.49275),
        Coordinate(latitude: 13.32052, longitude: 52.50190),
        Coordinate(latitude: 13.34577, longitude: 52.50134),
        Coordinate(latitude: 13.36903, longitude: 52.50701),
        Coordinate(latitude: 13.39155, longitude: 52.51046),
        Coordinate(latitude: 13.37256, longitude: 52.51598),
    ]),
    ("London", Money(currency: .gbp, value: 500), [
        Coordinate(latitude: 51.48205, longitude: 0.04283),
        Coordinate(latitude: 51.47439, longitude: 0.02170),
        Coordinate(latitude: 51.47618, longitude: 0.02199),
        Coordinate(latitude: 51.49295, longitude: 0.05658),
        Coordinate(latitude: 51.47542, longitude: 0.03019),
        Coordinate(latitude: 51.47537, longitude: 0.03015),
        Coordinate(latitude: 51.47435, longitude: 0.03733),
        Coordinate(latitude: 51.47954, longitude: 0.04866),
        Coordinate(latitude: 51.48604, longitude: 0.06293),
        Coordinate(latitude: 51.49314, longitude: 0.06104),
        Coordinate(latitude: 51.49248, longitude: 0.04740),
        Coordinate(latitude: 51.48888, longitude: 0.03564),
        Coordinate(latitude: 51.48655, longitude: 0.01830),
        Coordinate(latitude: 51.48085, longitude: -0.02223),
        Coordinate(latitude: 51.49210, longitude: -0.04510),
        Coordinate(latitude: 51.49324, longitude: -0.04699),
        Coordinate(latitude: 51.50959, longitude: -0.05491),
        Coordinate(latitude: 51.50961, longitude: -0.05390),
        Coordinate(latitude: 51.49950, longitude: -0.01356),
        Coordinate(latitude: 51.50898, longitude: -0.02341),
        Coordinate(latitude: 51.51069, longitude: -0.04225),
        Coordinate(latitude: 51.51056, longitude: -0.04353),
        Coordinate(latitude: 51.50946, longitude: -0.07810),
        Coordinate(latitude: 51.51121, longitude: -0.09786),
        Coordinate(latitude: 51.50964, longitude: -0.11870),
        Coordinate(latitude: 51.50273, longitude: -0.13850),
        Coordinate(latitude: 51.50095, longitude: -0.12411),
    ])
]

let logs = """
    Test Suite 'All tests' started at 2020-08-19 12:36:12.062
    Test Suite 'VoiceMemosTests.xctest' started at 2020-08-19 12:36:12.062
    Test Suite 'VoiceMemosTests' started at 2020-08-19 12:36:12.062
    Test Case '-[VoiceMemosTests.VoiceMemosTests testDeleteMemo]' started.
    Test Case '-[VoiceMemosTests.VoiceMemosTests testDeleteMemo]' passed (0.004 seconds).
    Test Case '-[VoiceMemosTests.VoiceMemosTests testDeleteMemoWhilePlaying]' started.
    Test Case '-[VoiceMemosTests.VoiceMemosTests testDeleteMemoWhilePlaying]' passed (0.002 seconds).
    Test Case '-[VoiceMemosTests.VoiceMemosTests testPermissionDenied]' started.
    /Users/point-free/projects/swift-composable-architecture/Examples/VoiceMemos/VoiceMemosTests/VoiceMemosTests.swift:107: error: -[VoiceMemosTests.VoiceMemosTests testPermissionDenied] : XCTAssertTrue failed
    Test Case '-[VoiceMemosTests.VoiceMemosTests testPermissionDenied]' failed (0.003 seconds).
    Test Case '-[VoiceMemosTests.VoiceMemosTests testPlayMemoFailure]' started.
    Test Case '-[VoiceMemosTests.VoiceMemosTests testPlayMemoFailure]' passed (0.002 seconds).
    Test Case '-[VoiceMemosTests.VoiceMemosTests testPlayMemoHappyPath]' started.
    Test Case '-[VoiceMemosTests.VoiceMemosTests testPlayMemoHappyPath]' passed (0.002 seconds).
    Test Case '-[VoiceMemosTests.VoiceMemosTests testRecordMemoFailure]' started.
    /Users/point-free/projects/swift-composable-architecture/Examples/VoiceMemos/VoiceMemosTests/VoiceMemosTests.swift:144: error: -[VoiceMemosTests.VoiceMemosTests testRecordMemoFailure] : State change does not match expectation: …
          VoiceMemosState(
        −   alert: nil,
        +   alert: AlertState<VoiceMemosAction>(
        +     title: "Voice memo recording failed.",
        +     message: nil,
        +     primaryButton: nil,
        +     secondaryButton: nil
        +   ),
            audioRecorderPermission: RecorderPermission.allowed,
            currentRecording: nil,
            voiceMemos: [
            ]
          )
    (Expected: −, Actual: +)
    Test Case '-[VoiceMemosTests.VoiceMemosTests testRecordMemoFailure]' failed (0.009 seconds).
    Test Case '-[VoiceMemosTests.VoiceMemosTests testRecordMemoHappyPath]' started.
    /Users/point-free/projects/swift-composable-architecture/Examples/VoiceMemos/VoiceMemosTests/VoiceMemosTests.swift:56: error: -[VoiceMemosTests.VoiceMemosTests testRecordMemoHappyPath] : State change does not match expectation: …
          VoiceMemosState(
            alert: nil,
            audioRecorderPermission: RecorderPermission.allowed,
            currentRecording: CurrentRecording(
              date: 2001-01-01T00:00:00Z,
        −     duration: 3.0,
        +     duration: 2.0,
              mode: Mode.recording,
              url: file:///tmp/DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF.m4a
            ),
            voiceMemos: [
            ]
          )
    (Expected: −, Actual: +)
    Test Case '-[VoiceMemosTests.VoiceMemosTests testRecordMemoHappyPath]' failed (0.006 seconds).
    Test Case '-[VoiceMemosTests.VoiceMemosTests testStopMemo]' started.
    Test Case '-[VoiceMemosTests.VoiceMemosTests testStopMemo]' passed (0.001 seconds).
    Test Suite 'VoiceMemosTests' failed at 2020-08-19 12:36:12.094.
    Executed 8 tests, with 3 failures (0 unexpected) in 0.029 (0.032) seconds
    Test Suite 'VoiceMemosTests.xctest' failed at 2020-08-19 12:36:12.094.
    Executed 8 tests, with 3 failures (0 unexpected) in 0.029 (0.032) seconds
    Test Suite 'All tests' failed at 2020-08-19 12:36:12.095.
    Executed 8 tests, with 3 failures (0 unexpected) in 0.029 (0.033) seconds
    2020-08-19 12:36:19.538 xcodebuild[45126:3958202] [MT] IDETestOperationsObserverDebug: 14.165 elapsed -- Testing started completed.
    2020-08-19 12:36:19.538 xcodebuild[45126:3958202] [MT] IDETestOperationsObserverDebug: 0.000 sec, +0.000 sec -- start
    2020-08-19 12:36:19.538 xcodebuild[45126:3958202] [MT] IDETestOperationsObserverDebug: 14.165 sec, +14.165 sec -- end
    Test session results, code coverage, and logs:
    /Users/point-free/Library/Developer/Xcode/DerivedData/ComposableArchitecture-fnpkwoynrpjrkrfemkkhfdzooaes/Logs/Test/Test-VoiceMemos-2020.08.19_12-35-57--0400.xcresult
    Failing tests:
    VoiceMemosTests:
        VoiceMemosTests.testPermissionDenied()
        VoiceMemosTests.testRecordMemoFailure()
        VoiceMemosTests.testRecordMemoHappyPath()
    """

enum TestResult: Equatable {
    case failed(
        testName: Substring,
        (file: Substring, line: Int, message: Substring),
        time: TimeInterval)

    case passed(
        testName: Substring,
        time: TimeInterval)

    static func == (lhs: TestResult, rhs: TestResult) -> Bool {
        switch (lhs, rhs) {
        case (let .passed(a1, b1), let .passed(a2, b2)):
            return a1 == a2 && b1 == b2
        case (let .failed(a1, b1, c1), let .failed(a2, b2, c2)):
            let b = b1.file == b2.file
                && b1.line == b2.line
                && b1.message == b2.message
            return a1 == a2 && b && c1 == c2
        default:
            return false
        }
    }
}

let logsParsed: [TestResult] = [
    .passed(testName: "testDeleteMemo", time: 0.004),
    .passed(testName: "testDeleteMemoWhilePlaying", time: 0.002),
    .failed(
        testName: "testPermissionDenied",
        (file: "VoiceMemosTests.swift", line: 107, message: "XCTAssertTrue failed"),
        time: 0.003),
    .passed(testName: "testPlayMemoFailure", time: 0.002),
    .passed(testName: "testPlayMemoHappyPath", time: 0.002),
    .failed(
        testName: "testRecordMemoFailure",
        (file: "VoiceMemosTests.swift", line: 144, message: "State change does not match expectation: …\n      VoiceMemosState(\n    −   alert: nil,\n    +   alert: AlertState<VoiceMemosAction>(\n    +     title: \"Voice memo recording failed.\",\n    +     message: nil,\n    +     primaryButton: nil,\n    +     secondaryButton: nil\n    +   ),\n        audioRecorderPermission: RecorderPermission.allowed,\n        currentRecording: nil,\n        voiceMemos: [\n        ]\n      )\n(Expected: −, Actual: +)"),
        time: 0.009),
    .failed(
        testName: "testRecordMemoHappyPath",
        (file: "VoiceMemosTests.swift", line: 56, message: "State change does not match expectation: …\n      VoiceMemosState(\n        alert: nil,\n        audioRecorderPermission: RecorderPermission.allowed,\n        currentRecording: CurrentRecording(\n          date: 2001-01-01T00:00:00Z,\n    −     duration: 3.0,\n    +     duration: 2.0,\n          mode: Mode.recording,\n          url: file:///tmp/DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF.m4a\n        ),\n        voiceMemos: [\n        ]\n      )\n(Expected: −, Actual: +)"),
        time: 0.006),
    .passed(testName: "testStopMemo", time: 0.001)
]
