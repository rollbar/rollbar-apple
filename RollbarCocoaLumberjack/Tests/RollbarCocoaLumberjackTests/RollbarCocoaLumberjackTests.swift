import XCTest
import UnitTesting
import RollbarNotifier
import CocoaLumberjackSwift
@testable import RollbarCocoaLumberjack

final class RollbarCocoaLumberjackTests: XCTestCase {
    
    override func setUp() {
        
        super.setUp();
        
        RollbarLogger.clearSdkDataStore();
        
        let rollbarConfig = RollbarConfig();
        rollbarConfig.destination.accessToken = RollbarTestHelper.getRollbarPayloadsAccessToken();
        rollbarConfig.destination.environment = RollbarTestHelper.getRollbarEnvironment();
        //rollbarConfig.developerOptions.transmit = false;
        
        XCTAssertTrue(RollbarLogger.readLogItemsFromStore().count == 0);
        XCTAssertEqual(RollbarLogger.readLogItemsFromStore().count, 0);

        dynamicLogLevel = DDLogLevel.debug;
        DDLog.add(DDOSLogger .sharedInstance);
        let ddFileLogger = DDFileLogger();
        ddFileLogger.rollingFrequency = 60 * 60 * 24; // 24-hours rolling
        ddFileLogger.logFileManager.maximumNumberOfLogFiles = 1;
        // he above code tells the application to keep a day worth of log files on the system.
        DDLog.add(ddFileLogger);
        
        DDLog.add(RollbarCocoaLumberjackLogger.create(with: rollbarConfig));
    }
    
    func testBasics() {
        
        XCTAssertEqual(RollbarLogger.readLogItemsFromStore().count, 0);
        
        DDLogError("Get it to Rollbar!");
        
        //Thread.sleep(forTimeInterval: 5.0);

        XCTAssertEqual(RollbarLogger.readLogItemsFromStore().count, 1);
    }

    func testBasicsMore() {
        
    }

//    func testExample() throws {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct
//        // results.
//        //XCTAssertEqual(RollbarCocoaLumberjack().text, "Hello, World!")
//    }
    
//    static var allTests = [
//        ("testBasics", testBasics),
//        ("testExample", testExample),
//    ]
}
