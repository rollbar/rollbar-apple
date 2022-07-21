@import Foundation;
@import UnitTesting;

#if !TARGET_OS_WATCH
#import <XCTest/XCTest.h>

@import RollbarNotifier;

@interface RollbarConfigurationTests : XCTestCase

@end

@implementation RollbarConfigurationTests

- (void)setUp {

    [super setUp];
    
    [RollbarLogger clearSdkDataStore];
    
    RollbarMutableConfig *config =
    [RollbarMutableConfig mutableConfigWithAccessToken:[RollbarTestHelper getRollbarPayloadsAccessToken]
                                           environment:[RollbarTestHelper getRollbarEnvironment]];
    [Rollbar initWithConfiguration:config];
    
    [NSThread sleepForTimeInterval:1.0f];
    [RollbarLogger clearSdkDataStore];
    NSArray *items = [RollbarLogger readLogItemsFromStore];
    XCTAssertEqual(items.count, 0);

}

- (void)tearDown {
    
    [Rollbar updateConfiguration:[RollbarConfig new]];
    [super tearDown];
}

- (void)testConfigCloning {

    RollbarMutableConfig *rc = [RollbarMutableConfig new];
    NSString *customEnv = @"CUSTOM_ENV";

    XCTAssertNotEqual(rc.destination.environment, customEnv);
    XCTAssertFalse(NSOrderedSame == [rc.destination.environment compare: customEnv]);
    rc.destination.environment = customEnv;
    XCTAssertTrue(NSOrderedSame == [rc.destination.environment compare: customEnv]);

    RollbarConfig *rcClone = (RollbarConfig *)[rc copy];
    XCTAssertNotEqual(rc.destination, rcClone.destination);
    XCTAssertTrue(NSOrderedSame == [rcClone.destination.environment compare: customEnv]);
}

- (void)testDefaultRollbarConfiguration {
    
    RollbarConfig *rc = [RollbarConfig new];
    NSLog(@"%@", rc);
}

- (void)testScrubSafeListFields {
    
    NSString *scrubedContent = @"*****";
    NSArray *keys = @[@"client.ios.app_name", @"client.ios.os_version", @"body.message.body"];
    
    RollbarMutableConfig *config = [[Rollbar configuration] mutableCopy];
    // define scrub fields:
    for (NSString *key in keys) {
        [config.dataScrubber addScrubField:key];
    }
    [Rollbar updateConfiguration:config];
    [Rollbar debugMessage:@"test"];
    
    [RollbarLogger flushRollbarThread];
    
    // verify the fields were scrubbed:
    NSArray *logItems = [RollbarLogger readLogItemsFromStore];
    for (NSString *key in keys) {
        NSString *content = [logItems[0] valueForKeyPath:key];
        XCTAssertTrue([content isEqualToString:scrubedContent],
                      @"%@ is %@, should be %@",
                      key,
                      content,
                      scrubedContent
                      );
    }
    
    [RollbarLogger clearSdkDataStore];
    
    // define scrub whitelist fields (the same as the scrub fields - to counterbalance them):
    for (NSString *key in keys) {
        [config.dataScrubber addScrubSafeListField:key];
    }
    [Rollbar updateConfiguration:config];
    [Rollbar debugMessage:@"test"];
    
    [RollbarLogger flushRollbarThread];
    
    // verify the fields were not scrubbed:
    logItems = [RollbarLogger readLogItemsFromStore];
    for (NSString *key in keys) {
        NSString *content = [logItems[0] valueForKeyPath:key];
        XCTAssertTrue(![content isEqualToString:scrubedContent],
                      @"%@ is %@, should not be %@",
                      key,
                      content,
                      scrubedContent
                      );
    }
}

- (void)testTelemetryEnabled {
    
    [RollbarLogger clearSdkDataStore];
    
    BOOL expectedFlag = NO;
    RollbarMutableConfig *config = [[Rollbar configuration] mutableCopy];
    config.telemetry.enabled = expectedFlag;
    [Rollbar updateConfiguration:config];

    XCTAssertTrue(RollbarTelemetry.sharedInstance.enabled == expectedFlag,
                  @"RollbarTelemetry.sharedInstance.enabled is expected to be NO."
                  );
    int max = 5;
    int testCount = max;
    for (int i=0; i<testCount; i++) {
        [Rollbar recordErrorEventForLevel:RollbarLevel_Debug message:@"test"];
    }

    config.loggingOptions.maximumReportsPerMinute = max;
    NSArray *telemetryCollection = [[RollbarTelemetry sharedInstance] getAllData];
    XCTAssertTrue(telemetryCollection.count == 0,
                  @"Telemetry count is expected to be %i. Actual is %lu",
                  0,
                  (unsigned long) telemetryCollection.count
                  );

    expectedFlag = YES;
    config.telemetry.enabled = expectedFlag;
    [Rollbar updateConfiguration:config];

    XCTAssertTrue(RollbarTelemetry.sharedInstance.enabled == expectedFlag,
                  @"RollbarTelemetry.sharedInstance.enabled is expected to be YES."
                  );
    for (int i=0; i<testCount; i++) {
        [Rollbar recordErrorEventForLevel:RollbarLevel_Debug message:@"test"];
    }
    config.loggingOptions.maximumReportsPerMinute = max;
    telemetryCollection = [[RollbarTelemetry sharedInstance] getAllData];
    XCTAssertTrue(telemetryCollection.count == max,
                  @"Telemetry count is expected to be %i. Actual is %lu",
                  max,
                  (unsigned long) telemetryCollection.count
                  );
    
    [RollbarTelemetry.sharedInstance clearAllData];
}

- (void)testScrubViewInputsTelemetryConfig {

    BOOL expectedFlag = NO;
    RollbarMutableConfig *config = [[Rollbar configuration] mutableCopy];
    config.telemetry.viewInputsScrubber.enabled = expectedFlag;
    [Rollbar updateConfiguration:config];

    XCTAssertTrue(RollbarTelemetry.sharedInstance.scrubViewInputs == expectedFlag,
                  @"RollbarTelemetry.sharedInstance.scrubViewInputs is expected to be NO."
                  );

    expectedFlag = YES;
    config.telemetry.viewInputsScrubber.enabled = expectedFlag;
    [Rollbar updateConfiguration:config];

    XCTAssertTrue(RollbarTelemetry.sharedInstance.scrubViewInputs == expectedFlag,
                  @"RollbarTelemetry.sharedInstance.scrubViewInputs is expected to be YES."
                  );
}

- (void)testViewInputTelemetrScrubFieldsConfig {

    NSString *element1 = @"password";
    NSString *element2 = @"pin";
    
    RollbarMutableConfig *config = [[Rollbar configuration] mutableCopy];
    [config.telemetry.viewInputsScrubber addScrubField:element1];
    [config.telemetry.viewInputsScrubber addScrubField:element2];
    [Rollbar updateConfiguration:config];

    XCTAssertTrue(
        RollbarTelemetry.sharedInstance.viewInputsToScrub.count == [RollbarScrubbingOptions new].scrubFields.count + 2,
        @"RollbarTelemetry.sharedInstance.viewInputsToScrub is expected to count = 2"
        );
    XCTAssertTrue(
        [RollbarTelemetry.sharedInstance.viewInputsToScrub containsObject:element1],
        @"RollbarTelemetry.sharedInstance.viewInputsToScrub is expected to conatin @%@",
        element1
        );
    XCTAssertTrue(
        [RollbarTelemetry.sharedInstance.viewInputsToScrub containsObject:element2],
        @"RollbarTelemetry.sharedInstance.viewInputsToScrub is expected to conatin @%@",
        element2
        );
    
    [config.telemetry.viewInputsScrubber removeScrubField:element1];
    [config.telemetry.viewInputsScrubber removeScrubField:element2];
    [Rollbar updateConfiguration:config];

    XCTAssertTrue(
        RollbarTelemetry.sharedInstance.viewInputsToScrub.count == [RollbarScrubbingOptions new].scrubFields.count,
        @"RollbarTelemetry.sharedInstance.viewInputsToScrub is expected to count = 0"
        );
}

- (void)testEnabled {
    
    [RollbarLogger clearSdkDataStore];

    NSArray *logItems = [RollbarLogger readLogItemsFromStore];
    XCTAssertTrue(logItems.count == 0,
                  @"logItems count is expected to be 0. Actual value is %lu",
                  (unsigned long) logItems.count
                  );


    RollbarMutableConfig *config = [[Rollbar configuration] mutableCopy];
    config.developerOptions.enabled = NO;
    //Rollbar.currentLogger.configuration.developerOptions.enabled = NO;
    [Rollbar updateConfiguration:config];
    [Rollbar debugMessage:@"Test1"];
    [RollbarLogger flushRollbarThread];

    logItems = [RollbarLogger readLogItemsFromStore];
    XCTAssertTrue(logItems.count == 0,
                  @"logItems count is expected to be 0. Actual value is %lu",
                  (unsigned long) logItems.count
                  );

    config.developerOptions.enabled = YES;
    [Rollbar updateConfiguration:config];
    [Rollbar debugMessage:@"Test2"];
    [RollbarLogger flushRollbarThread];

    logItems = [RollbarLogger readLogItemsFromStore];
    XCTAssertTrue(logItems.count == 1,
                  @"logItems count is expected to be 1. Actual value is %lu",
                  (unsigned long) logItems.count
                  );

    config.developerOptions.enabled = NO;
    [Rollbar updateConfiguration:config];
    [Rollbar debugMessage:@"Test3"];
    [RollbarLogger flushRollbarThread];

    logItems = [RollbarLogger readLogItemsFromStore];
    XCTAssertTrue(logItems.count == 1,
                  @"logItems count is expected to be 1. Actual value is %lu",
                  (unsigned long) logItems.count
                  );
    
    [RollbarLogger clearSdkDataStore];
}

- (void)testMaximumTelemetryEvents {
    
    RollbarMutableConfig *config = [[Rollbar configuration] mutableCopy];
    config.telemetry.enabled = YES;
    [Rollbar updateConfiguration:config];

    int testCount = 10;
    int max = 5;
    for (int i=0; i<testCount; i++) {
        [Rollbar recordErrorEventForLevel:RollbarLevel_Debug message:@"test"];
    }

    config.telemetry.maximumTelemetryData = max;
    [Rollbar updateConfiguration:config];
    
    [Rollbar debugMessage:@"Test"];
    [RollbarLogger flushRollbarThread];

    NSArray *logItems = [RollbarLogger readLogItemsFromStore];
    NSDictionary *item = logItems[0];
    NSArray *telemetryData = [item valueForKeyPath:@"body.telemetry"];
    XCTAssertTrue(telemetryData.count == max,
                  @"Telemetry item count is %lu, should be %lu",
                  (unsigned long) telemetryData.count,
                  (long)max
                  );
}

- (void)testCheckIgnore {
    
    [Rollbar debugMessage:@"Don't ignore this"];
    [RollbarLogger flushRollbarThread];

    NSArray *logItems = [RollbarLogger readLogItemsFromStore];
    XCTAssertTrue(logItems.count == 1, @"Log item count should be 1");

    RollbarMutableConfig *config = [[Rollbar configuration] mutableCopy];
    config.checkIgnoreRollbarData = ^BOOL(RollbarData *payloadData) {
        return true;
    };
    [Rollbar updateConfiguration:config];
    [Rollbar debugMessage:@"Ignore this"];
    logItems = [RollbarLogger readLogItemsFromStore];
    XCTAssertTrue(logItems.count == 1, @"Log item count should be 1");
}

- (void)testServerData {
    
    RollbarMutableConfig *config = [[Rollbar configuration] mutableCopy];
    NSString *host = @"testHost";
    NSString *root = @"testRoot";
    NSString *branch = @"testBranch";
    NSString *codeVersion = @"testCodeVersion";
    [config setServerHost:host
                                           root:root
                                         branch:branch
                                    codeVersion:codeVersion
    ];
    [Rollbar updateConfiguration:config];
    [Rollbar debugMessage:@"test"];

    [RollbarLogger flushRollbarThread];

    NSArray *logItems = [RollbarLogger readLogItemsFromStore];
    NSDictionary *item = logItems[0];
    NSDictionary *server = item[@"server"];

    XCTAssertTrue([host isEqualToString:server[@"host"]],
                  @"host is %@, should be %@",
                  server[@"host"],
                  host
                  );
    XCTAssertTrue([root isEqualToString:server[@"root"]],
                  @"root is %@, should be %@",
                  server[@"root"],
                  root
                  );
    XCTAssertTrue([branch isEqualToString:server[@"branch"]],
                  @"branch is %@, should be %@",
                  server[@"branch"],
                  branch
                  );
    XCTAssertTrue([codeVersion isEqualToString:server[@"code_version"]],
                  @"code_version is %@, should be %@",
                  server[@"code_version"],
                  codeVersion
                  );
}

- (void)testPayloadModification {
    
    NSString *newMsg = @"Modified message";
    RollbarMutableConfig *config = [[Rollbar configuration] mutableCopy];
    config.modifyRollbarData = ^RollbarData *(RollbarData *payloadData) {
//        [payloadData setValue:newMsg forKeyPath:@"body.message.body"];
//        [payloadData setValue:newMsg forKeyPath:@"body.message.body2"];
        payloadData.body.message.body = newMsg;
        [payloadData.body.message addKeyed:@"body2" String:newMsg];
        return payloadData;
    };
    [Rollbar updateConfiguration:config];
    [Rollbar debugMessage:@"test"];

    [RollbarLogger flushRollbarThread];

    NSArray *logItems = [RollbarLogger readLogItemsFromStore];
    NSString *msg1 = [logItems[0] valueForKeyPath:@"body.message.body"];
    NSString *msg2 = [logItems[0] valueForKeyPath:@"body.message.body2"];

    XCTAssertTrue([msg1 isEqualToString:newMsg],
                  @"body.message.body is %@, should be %@",
                  msg1,
                  newMsg
                  );
    XCTAssertTrue([msg1 isEqualToString:newMsg],
                  @"body.message.body2 is %@, should be %@",
                  msg2,
                  newMsg
                  );
}

- (void)testScrubField {
    
    NSString *scrubedContent = @"*****";
    NSArray *keys = @[@"client.ios.app_name", @"client.ios.os_version", @"body.message.body"];

    RollbarMutableConfig *config = [[Rollbar configuration] mutableCopy];
    for (NSString *key in keys) {
        [config.dataScrubber addScrubField:key];
    }
    [Rollbar updateConfiguration:config];
    [Rollbar debugMessage:@"test"];

    [RollbarLogger flushRollbarThread];

    NSArray *logItems = [RollbarLogger readLogItemsFromStore];
    for (NSString *key in keys) {
        NSString *content = [logItems[0] valueForKeyPath:key];
        XCTAssertTrue([content isEqualToString:scrubedContent],
                      @"%@ is %@, should be %@",
                      key,
                      content,
                      scrubedContent
                      );
    }
}

- (void)testLogTelemetryAutoCapture {
    
    NSString *logMsg = @"log-message-testing";
    [[RollbarTelemetry sharedInstance] clearAllData];

    RollbarMutableConfig *config = [[Rollbar configuration] mutableCopy];
    config.telemetry.enabled = YES;
    config.telemetry.captureLog = YES;
    [Rollbar updateConfiguration:config];
    [RollbarLogger flushRollbarThread];
    [RollbarLogger clearSdkDataStore];

    // The following line ensures the captureLogAsTelemetryData setting is flushed through the internal queue
    [[RollbarTelemetry sharedInstance] getAllData];
    NSLog(logMsg);
    [Rollbar debugMessage:@"test"];
    
    [RollbarLogger flushRollbarThread];

    NSArray *logItems = [RollbarLogger readLogItemsFromStore];
    NSArray *telemetryData = [logItems[0] valueForKeyPath:@"body.telemetry"];
    NSString *telemetryMsg = [telemetryData[0] valueForKeyPath:@"body.message"];
    XCTAssertTrue([logMsg isEqualToString:telemetryMsg],
                  @"body.telemetry[0].body.message is %@, should be %@",
                  telemetryMsg,
                  logMsg
                  );
    
    //[NSThread sleepForTimeInterval:3.0f];
}

@end
#endif
