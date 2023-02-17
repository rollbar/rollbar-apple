#if !os(watchOS)
import XCTest
import Foundation
import UnitTesting
import os.log
@testable import RollbarNotifier

final class RollbarNotifierLoggerTests: XCTestCase {
    
    override func setUp() {
        
        super.setUp();
        
        RollbarTestUtil.deletePayloadsStoreFile();
        RollbarTestUtil.clearTelemetryFile();
        RollbarTestUtil.deleteLogFiles();

        let config = RollbarMutableConfig.mutableConfig(
            withAccessToken: RollbarTestHelper.getRollbarPayloadsAccessToken(),
            environment: RollbarTestHelper.getRollbarEnvironment()
        );
        config.developerOptions.transmit = true;
        config.developerOptions.logTransmittedPayloads = true;
        config.developerOptions.logDroppedPayloads = true;
        config.loggingOptions.maximumReportsPerMinute = 5000;
        config.customData = ["someKey": "someValue", ];
        
        Rollbar.initWithConfiguration(config);
        
        RollbarTestUtil.wait(waitTimeInSeconds: 1);
        RollbarLogger.flushRollbarThread();
        RollbarTestUtil.deleteLogFiles();
        RollbarTestUtil.wait(waitTimeInSeconds: 1);
        
        XCTAssertEqual(0, RollbarTestUtil.readIncomingPayloadsAsStrings().count);
        XCTAssertEqual(0, RollbarTestUtil.readTransmittedPayloadsAsStrings().count);
        XCTAssertEqual(0, RollbarTestUtil.readDroppedPayloadsAsStrings().count);
    }
    
    override func tearDown() {
        
        RollbarTestUtil.wait(waitTimeInSeconds: 1);

        super.tearDown();
    }
    
    func testRollbarConfiguration() {
        NSLog("%@", Rollbar.configuration());
    }

    func testRollbarNotifiersIndependentConfiguration() {

        var config = Rollbar.configuration().mutableCopy();
        config.developerOptions.transmit = false;
        config.developerOptions.logIncomingPayloads = true;
        config.developerOptions.logTransmittedPayloads = true;
        config.developerOptions.logDroppedPayloads = true;

        // configure the shared notifier:
        config.destination.accessToken = "AT_0";
        config.destination.environment = "ENV_0";

        Rollbar.update(withConfiguration: config);
        XCTAssertEqual(RollbarInfrastructure.sharedInstance().logger.configuration!.destination.accessToken,
                       config.destination.accessToken);
        XCTAssertEqual(RollbarInfrastructure.sharedInstance().logger.configuration!.destination.environment,
                       config.destination.environment);
        
        XCTAssertEqual(RollbarInfrastructure.sharedInstance().logger.configuration!.destination.accessToken,
                       config.destination.accessToken);
        XCTAssertEqual(RollbarInfrastructure.sharedInstance().logger.configuration?.destination.environment,
                       config.destination.environment);
        
        // create and configure another notifier:
        config = Rollbar.configuration().mutableCopy();
        config.destination.accessToken = "AT_1";
        config.destination.environment = "ENV_1";

        // reconfigure the root notifier:
        config = Rollbar.configuration().mutableCopy();
        config.destination.accessToken = "AT_N";
        config.destination.environment = "ENV_N";
        Rollbar.update(withConfiguration: config);
        XCTAssertTrue(RollbarInfrastructure.sharedInstance().logger.configuration!.destination.accessToken.compare("AT_N") == .orderedSame);
        XCTAssertTrue(RollbarInfrastructure.sharedInstance().logger.configuration!.destination.environment.compare("ENV_N") == .orderedSame);

        //TODO: to make this test even more valuable we need to make sure the other notifier's payloads
        //      are actually sent to its intended destination. But that is something we will be able to do
        //      once we add to this SDK a feature similar to Rollbar.NET's Internal Events...
    }

//    func testRollbarTransmit() {
//
//        let config = Rollbar.configuration().mutableCopy();
//        config.destination.accessToken = RollbarTestHelper.getRollbarPayloadsAccessToken();
//        config.destination.environment = RollbarTestHelper.getRollbarEnvironment();
//        config.developerOptions.transmit = true;
//
//        config.developerOptions.transmit = true;
//        Rollbar.update(withConfiguration: config);
//        Rollbar.criticalMessage("Transmission test YES");
//        RollbarTestUtil.wait(waitTimeInSeconds: 1.0);
//
//        config.developerOptions.transmit = false;
//        Rollbar.update(withConfiguration: config);
//        Rollbar.criticalMessage("Transmission test NO");
//        RollbarTestUtil.wait(waitTimeInSeconds: 1.0);
//
//        config.developerOptions.transmit = true;
//        Rollbar.update(withConfiguration: config);
//        Rollbar.criticalMessage("Transmission test YES2");
//        RollbarTestUtil.wait(waitTimeInSeconds: 1.0);
//
//        var count = 50;
//        while (count > 0) {
//            Rollbar.criticalMessage("Rate Limit Test \(count)");
//            RollbarTestUtil.wait(waitTimeInSeconds: 1.0);
//            count -= 1;
//        }
//    }
//
//    func testNotification() {
//
//        let notificationText = [
//            "error": ["testing-error"],
//            "debug": ["testing-debug"],
//            "warning": ["testing-warning"],
//            "info": ["testing-info"],
//            "critical": ["testing-critical"]
//        ];
//
//        for type in notificationText.keys {
//            let params = notificationText[type]!;
//            if (type.compare("error") == .orderedSame) {
//                Rollbar.errorMessage(params[0] as String);
//            } else if (type.compare("warning") == .orderedSame) {
//                Rollbar.warningMessage(params[0] as String);
//            } else if (type.compare("debug") == .orderedSame) {
//                Rollbar.debugMessage(params[0] as String);
//            } else if (type.compare("info") == .orderedSame) {
//                Rollbar.infoMessage(params[0] as String);
//            } else if (type.compare("critical") == .orderedSame) {
//                Rollbar.criticalMessage(params[0] as String);
//            }
//        }
//
//        RollbarLogger.flushRollbarThread();
//        RollbarTestUtil.wait(waitTimeInSeconds: 6.0);
//
//        let items = RollbarTestUtil.readTransmittedPayloadsAsStrings();
//        XCTAssertTrue(items.count >= notificationText.count);
//        var count:Int = 0;
//        for item in items {
//            if (!item.contains("testing-")) {
//                continue;
//            }
//            let payload = RollbarPayload(jsonString: item);
//            let level = payload.data.level;
//            let message: String? = payload.data.body.message?.body;
//            let params = notificationText[RollbarLevelUtil.rollbarLevel(toString: level)]!;
//            XCTAssertTrue(message!.compare(params[0] as String) == .orderedSame, "Expects '\(params[0])', got '\(message ?? "")'.");
//            count += 1;
//        }
//        XCTAssertEqual(count, notificationText.count);
//    }
    
//    func testNSErrorReporting() {
//        do {
//            try RollbarTestUtil.makeTroubledCall();
//            //var expectedErrorCallDepth: uint = 5;
//            //try RollbarTestUtil.simulateError(callDepth: &expectedErrorCallDepth);
//        }
//        catch RollbarTestUtilError.simulatedException(let errorDescription, let errorCallStack) {
//            print("Caught an error: \(errorDescription)");
//            print("Caught error's call stack:");
//            errorCallStack.forEach({print($0)});
//        }
//        catch let e as BackTracedErrorProtocol {
//            //print("Caught an error: \(e.localizedDescription)");
//            print("Caught an error: \(e.errorDescription)");
//            print("Caught error's call stack:");
//            e.errorCallStack.forEach({print($0)});
//        }
//        catch {
//            print("Caught an error: \(error)");
//            //print("Caught an error: \(error.localizedDescription)");
//            //print("Corresponding call stack trace at the catch point:");
//            Thread.callStackSymbols.forEach{print($0)}
//        }
//    }
    
    static var allTests = [
        ("testRollbarConfiguration", testRollbarConfiguration),
        ("testRollbarNotifiersIndependentConfiguration", testRollbarNotifiersIndependentConfiguration),
        //("testRollbarTransmit", testRollbarTransmit),
        //("testNotification", testNotification),
        //("testNSErrorReporting", testNSErrorReporting),
    ]
}
#endif
