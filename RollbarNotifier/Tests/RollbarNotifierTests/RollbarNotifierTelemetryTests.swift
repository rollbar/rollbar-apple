#if !os(watchOS)
import XCTest
import Foundation
import UnitTesting
//import os.log
@testable import RollbarNotifier

final class RollbarNotifierTelemetryTests: XCTestCase {
    
    override func setUp() {
        
        super.setUp();
        RollbarTestUtil.clearLogFile();
        RollbarTestUtil.clearTelemetryFile();
        
        let config = RollbarConfig.mutableConfig(
            withAccessToken: RollbarTestHelper.getRollbarPayloadsAccessToken(),
            environment: RollbarTestHelper.getRollbarEnvironment()
        );
        Rollbar.update(withConfiguration: config);
    }
    
    override func tearDown() {
        Rollbar.update(withConfiguration: RollbarMutableConfig());
        super.tearDown();
    }
    
    func testMemoryTelemetryAutocapture() {
        
        RollbarTestUtil.clearLogFile();
        RollbarTestUtil.clearTelemetryFile();
        
        let config = RollbarMutableConfig();
        config.destination.accessToken = RollbarTestHelper.getRollbarPayloadsAccessToken();
        config.destination.environment = RollbarTestHelper.getRollbarEnvironment();
        config.developerOptions.transmit = false;
        config.telemetry.enabled = true;
        config.telemetry.memoryStatsAutocollectionInterval = 0.5;
        Rollbar.update(withConfiguration: config);
        
        Thread.sleep(forTimeInterval: 5.0);
        Rollbar.criticalMessage("Must contain memory telemetry!");
        RollbarLogger.flushRollbarThread();

        let logItems = RollbarTestUtil.readItemStringsFromLogFile();
        let logItem = logItems[logItems.count - 1];
        let payload = RollbarPayload(jsonString: logItem);
        let telemetryEvents = payload.data.body.telemetry!;
        XCTAssertTrue(telemetryEvents.count > 0);
        var totalMemoryStatsEvents = 0;
        for event in telemetryEvents {
            if (event.type == RollbarTelemetryType.manual) {
                if let content = event.body as? RollbarTelemetryManualBody {
                    if !content.isEmpty && content.description.contains("memory_stats") {
                        totalMemoryStatsEvents += 1;
                    }
                }
            }
        }
        XCTAssertTrue(totalMemoryStatsEvents > 0);
    }

    func testMemoryTelemetryAutocapture_Live() {
        
        RollbarTestUtil.clearLogFile();
        RollbarTestUtil.clearTelemetryFile();
        
        let config = RollbarMutableConfig();
        config.destination.accessToken = RollbarTestHelper.getRollbarPayloadsAccessToken();
        config.destination.environment = RollbarTestHelper.getRollbarEnvironment();
        config.telemetry.enabled = true;
        config.telemetry.memoryStatsAutocollectionInterval = 0.5;

        Rollbar.update(withConfiguration: config);
        
        //let resultingConfig = Rollbar.currentConfiguration();
        Rollbar.criticalMessage("Rollbar will be testing memory telemetry!");
        RollbarTestUtil.waitForPesistenceToComplete();
        Thread.sleep(forTimeInterval: 2.0);
        Rollbar.criticalMessage("Must contain memory telemetry!");
        RollbarTestUtil.waitForPesistenceToComplete();
        Thread.sleep(forTimeInterval: 3.0);
    }
    
    func testTelemetryCapture() {
        
        RollbarTestUtil.clearLogFile();
        RollbarTestUtil.clearTelemetryFile();

        let config = Rollbar.configuration().mutableCopy();
        config.telemetry.enabled = true;
        Rollbar.update(withConfiguration: config);
        RollbarLogger.flushRollbarThread();

        Rollbar.recordNavigationEvent(
            for: .info,
            from: "from",
            to: "to"
        );
        Rollbar.recordConnectivityEvent(
            for: .info,
            status: "connactivity_status"
        );
        Rollbar.recordNetworkEvent(
            for: .info,
            method: "DELETE",
            url: "url",
            statusCode: "status_code",
            extraData: nil
        );
        Rollbar.recordErrorEvent(
            for: .debug,
            message: "test"
        );
        Rollbar.recordErrorEvent(
            for: .error,
            exception: NSException(name: NSExceptionName(rawValue: "name"), reason: "reason", userInfo: nil)
        );
        Rollbar.recordManualEvent(
            for: .debug,
            withData: ["data" : "content"]
        );

        RollbarLogger.flushRollbarThread();
        Rollbar.debugMessage("Test");
        RollbarLogger.flushRollbarThread();

        let logItems = RollbarTestUtil.readItemStringsFromLogFile();
        let logItem = logItems[logItems.count - 1];
        let payload = RollbarPayload(jsonString: logItem);
        let telemetryEvents = payload.data.body.telemetry!;
        XCTAssertTrue(telemetryEvents.count > 0);

        for event in telemetryEvents {
            switch event.type {
            case .error:
                let body = event.body as! RollbarTelemetryErrorBody;
                switch event.level {
                case .error:
                    XCTAssertTrue(body.message.compare("reason") == .orderedSame);
                    let exceptionClass = body.getDataByKey("class") as! String;
                    XCTAssertTrue(exceptionClass.compare("NSException") == .orderedSame);
                    let description = body.getDataByKey("description") as! String;
                    XCTAssertTrue(description.compare("reason") == .orderedSame);
                case .debug:
                    XCTAssertTrue(body.message.compare("test") == .orderedSame);
                default:
                    XCTFail();
                }
            case .navigation:
                let body = event.body as! RollbarTelemetryNavigationBody;
                XCTAssertEqual(body.from, "from");
                XCTAssertEqual(body.to, "to");
            case .network:
                let body = event.body as! RollbarTelemetryNetworkBody;
                XCTAssertEqual(body.method, .delete);
                XCTAssertEqual(body.statusCode, "status_code");
                XCTAssertEqual(body.url, "url");
            case .connectivity:
                let body = event.body as! RollbarTelemetryConnectivityBody;
                XCTAssertEqual(body.status, "connactivity_status");
            case .manual:
                let body = event.body as! RollbarTelemetryManualBody;
                let data = body.getDataByKey("data") as! String;
                XCTAssertTrue(data.compare("content") == .orderedSame);
            //case .log:
            //case .view:
            //@unknown default:
            default:
                break;
            }
        }
    }
    
    func testErrorReportingWithTelemetry() {
        
        RollbarTestUtil.clearLogFile();
        RollbarTestUtil.clearTelemetryFile();

        let config = Rollbar.configuration().mutableCopy();
        config.telemetry.enabled = true;
        Rollbar.update(withConfiguration: config);

        Rollbar.recordNavigationEvent(
            for: .info,
            from: "SomeNavigationSource",
            to: "SomeNavigationDestination"
        );
        Rollbar.recordConnectivityEvent(
            for: .info,
            status: "SomeConnectivityStatus"
        );
        Rollbar.recordNetworkEvent(
            for: .info,
            method: "POST",
            url: "www.myservice.com",
            statusCode: "200",
            extraData: nil
        );
        Rollbar.recordErrorEvent(
            for: .debug,
            message: "Some telemetry message..."
        );
        Rollbar.recordErrorEvent(
            for: .error,
            exception: NSException(
                name: NSExceptionName(rawValue: "someExceptionName"),
                reason: "someExceptionReason",
                userInfo: nil
            )
        );
        Rollbar.recordManualEvent(
            for: .debug,
            withData: ["myTelemetryParameter": "itsValue"]
        );

        //RollbarTestUtil.waitForPesistenceToComplete();

        Rollbar.debugMessage("Demonstrate Telemetry capture");
        Rollbar.debugMessage("Demonstrate Telemetry capture once more...");
        Rollbar.debugMessage("DO Demonstrate Telemetry capture once more...");

        RollbarTestUtil.waitForPesistenceToComplete();
        
        let logItems = RollbarTestUtil.readItemStringsFromLogFile();
        for item in logItems {
            let payload = RollbarPayload(jsonString: item);
            let telemetryEvents = payload.data.body.telemetry;
            for event in telemetryEvents! {
                switch event.type {
                case .error:
                    let body = event.body as! RollbarTelemetryErrorBody;
                    switch event.level {
                    case .error:
                        XCTAssertTrue(body.message.compare("someExceptionReason") == .orderedSame);
                        let exceptionClass = body.getDataByKey("class") as! String;
                        XCTAssertTrue(exceptionClass.compare("NSException") == .orderedSame);
                        let description = body.getDataByKey("description") as! String;
                        XCTAssertTrue(description.compare("someExceptionReason") == .orderedSame);
                    case .debug:
                        XCTAssertTrue(body.message.compare("Some telemetry message...") == .orderedSame);
                    default:
                        XCTFail();
                    }
                case .navigation:
                    let body = event.body as! RollbarTelemetryNavigationBody;
                    XCTAssertEqual(body.from, "SomeNavigationSource");
                    XCTAssertEqual(body.to, "SomeNavigationDestination");
                case .connectivity:
                    let body = event.body as! RollbarTelemetryConnectivityBody;
                    XCTAssertEqual(body.status, "SomeConnectivityStatus");
                case .network:
                    let body = event.body as! RollbarTelemetryNetworkBody;
                    XCTAssertEqual(body.method, .post);
                    XCTAssertEqual(body.statusCode, "200");
                    XCTAssertEqual(body.url, "www.myservice.com");
                case .manual:
                    let body = event.body as! RollbarTelemetryManualBody;
                    let data = body.getDataByKey("myTelemetryParameter") as! String;
                    XCTAssertTrue(data.compare("itsValue") == .orderedSame);
                default:
                    break;
                }
            }

        }
    }

    func testTelemetryViewEventScrubbing() {
        
        let config = Rollbar.configuration().mutableCopy();
        config.telemetry.enabled = true;
        config.telemetry.viewInputsScrubber.enabled = true;
        config.telemetry.viewInputsScrubber.scrubFields.add("password");
        config.telemetry.viewInputsScrubber.scrubFields.add("pin");        
        Rollbar.update(withConfiguration: config);
        
        Rollbar.recordViewEvent(
            for: .debug,
            element: "password",
            extraData: ["content": "My Password"]
        );
        Rollbar.recordViewEvent(
            for: .debug,
            element: "not-password",
            extraData: ["content": "My Password"]
        );

        let telemetryEvents = RollbarTelemetry.sharedInstance().getAllEvents();

        XCTAssertTrue("password".compare(telemetryEvents[0].value(forKeyPath: "body.element") as! String) == .orderedSame);
        XCTAssertTrue("[scrubbed]".compare(telemetryEvents[0].body.getDataByKey("content") as! String) == .orderedSame);

        XCTAssertTrue("not-password".compare(telemetryEvents[1].value(forKeyPath: "body.element") as! String) == .orderedSame);
        XCTAssertTrue("My Password".compare(telemetryEvents[1].body.getDataByKey("content") as! String) == .orderedSame);
    }
    
    static var allTests = [
        ("testMemoryTelemetryAutocapture", testMemoryTelemetryAutocapture),
        ("testMemoryTelemetryAutocapture_Live", testMemoryTelemetryAutocapture_Live),
        ("testTelemetryCapture", testTelemetryCapture),
        ("testErrorReportingWithTelemetry", testErrorReportingWithTelemetry),
        ("testTelemetryViewEventScrubbing", testTelemetryViewEventScrubbing),
    ]
}
#endif

