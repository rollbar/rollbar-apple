@import Foundation;
@import UnitTesting;

#if !TARGET_OS_WATCH
#import <XCTest/XCTest.h>

@import RollbarNotifier;

@interface RollbarTelemetryTests : XCTestCase

@end

@implementation RollbarTelemetryTests

- (void)setUp {

    [super setUp];

    [RollbarLogger clearSdkDataStore];
    
    RollbarMutableConfig *config =
    [RollbarMutableConfig mutableConfigWithAccessToken:[RollbarTestHelper getRollbarPayloadsAccessToken]
                                           environment:[RollbarTestHelper getRollbarEnvironment]];
    [Rollbar updateWithConfiguration:config];
}

- (void)tearDown {
    [Rollbar updateWithConfiguration:[RollbarConfig new]];
    [super tearDown];
}

- (void)testTelemetryCapture {
    
    RollbarMutableConfig *config = [[Rollbar configuration] mutableCopy];
    config.telemetry.enabled = YES;
    [Rollbar updateWithConfiguration:config];
    
    [Rollbar recordNavigationEventForLevel:RollbarLevel_Info from:@"from" to:@"to"];
    [Rollbar recordConnectivityEventForLevel:RollbarLevel_Info status:@"status"];
    [Rollbar recordNetworkEventForLevel:RollbarLevel_Info method:@"DELETE" url:@"url" statusCode:@"status_code" extraData:nil];
    [Rollbar recordErrorEventForLevel:RollbarLevel_Debug message:@"test"];
    [Rollbar recordErrorEventForLevel:RollbarLevel_Error exception:[NSException exceptionWithName:@"name" reason:@"reason" userInfo:nil]];
    [Rollbar recordManualEventForLevel:RollbarLevel_Debug withData:@{@"data": @"content"}];
    [Rollbar debugMessage:@"Test"];

    [RollbarLogger flushRollbarThread];

    NSArray *logItems = [RollbarLogger readPayloadsFromSdkTransmittedLog];
    NSDictionary *item = logItems[logItems.count - 1];
    NSArray *telemetryData = [item valueForKeyPath:@"body.telemetry"];
    XCTAssertTrue(telemetryData.count > 0);

    for (NSDictionary *data in telemetryData) {
        NSDictionary *body = data[@"body"];
        NSString *type = data[@"type"];
        if ([type isEqualToString:@"error"]) {
            if ([data[@"level"] isEqualToString:@"debug"]) {
                XCTAssertTrue([body[@"message"] isEqualToString:@"test"]);
            } else if ([data[@"level"] isEqualToString:@"error"]) {
                XCTAssertTrue([body[@"class"] isEqualToString:NSStringFromClass([NSException class])]);
                XCTAssertTrue([body[@"description"] isEqualToString:@"reason"]);
                XCTAssertTrue([body[@"message"] isEqualToString:@"reason"]);
            }
        } else if ([type isEqualToString:@"navigation"]) {
            XCTAssertTrue([body[@"from"] isEqualToString:@"from"]);
            XCTAssertTrue([body[@"to"] isEqualToString:@"to"]);
        } else if ([type isEqualToString:@"connectivity"]) {
            XCTAssertTrue([body[@"change"] isEqualToString:@"status"]);
        } else if ([type isEqualToString:@"network"]) {
            XCTAssertTrue([body[@"method"] isEqualToString:@"DELETE"]);
            XCTAssertTrue([body[@"status_code"] isEqualToString:@"status_code"]);
            XCTAssertTrue([body[@"url"] isEqualToString:@"url"]);
        } else if ([type isEqualToString:@"manual"]) {
            XCTAssertTrue([body[@"data"] isEqualToString:@"content"]);
        }
    }
}

- (void)testErrorReportingWithTelemetry {
    
    RollbarMutableConfig *config = [[Rollbar configuration] mutableCopy];
    config.telemetry.enabled = YES;
    [Rollbar updateWithConfiguration:config];

    [Rollbar recordNavigationEventForLevel:RollbarLevel_Info from:@"SomeNavigationSource" to:@"SomeNavigationDestination"];
    [Rollbar recordConnectivityEventForLevel:RollbarLevel_Info status:@"SomeConnectivityStatus"];
    [Rollbar recordNetworkEventForLevel:RollbarLevel_Info method:@"POST" url:@"www.myservice.com" statusCode:@"200" extraData:nil];
    [Rollbar recordErrorEventForLevel:RollbarLevel_Debug message:@"Some telemetry message..."];
    [Rollbar recordErrorEventForLevel:RollbarLevel_Error exception:
     [NSException exceptionWithName:@"someExceptionName"
                             reason:@"someExceptionReason"
                           userInfo:nil]];
    [Rollbar recordManualEventForLevel:RollbarLevel_Debug withData:@{@"myTelemetryParameter": @"itsValue"}];
    
    [Rollbar debugMessage:@"Demonstrate Telemetry capture"];
    [Rollbar debugMessage:@"Demonstrate Telemetry capture once more..."];
    [Rollbar debugMessage:@"DO Demonstrate Telemetry capture once more..."];

    //[NSThread sleepForTimeInterval:8.0f];
    
    NSArray *logItems = [RollbarLogger readPayloadsFromSdkTransmittedLog];
    for (NSDictionary *item in logItems) {
        NSArray *telemetryData = [item valueForKeyPath:@"body.telemetry"];

        for (NSDictionary *data in telemetryData) {
            NSDictionary *body = data[@"body"];
            NSString *type = data[@"type"];
            if ([type isEqualToString:@"error"]) {
                if ([data[@"level"] isEqualToString:@"debug"]) {
                    XCTAssertTrue([body[@"message"] isEqualToString:@"Some telemetry message..."]);
                } else if ([data[@"level"] isEqualToString:@"error"]) {
                    XCTAssertTrue([body[@"class"] isEqualToString:NSStringFromClass([NSException class])]);
                    XCTAssertTrue([body[@"description"] isEqualToString:@"someExceptionReason"]);
                    XCTAssertTrue([body[@"message"] isEqualToString:@"someExceptionReason"]);
                }
            } else if ([type isEqualToString:@"navigation"]) {
                XCTAssertTrue([body[@"from"] isEqualToString:@"SomeNavigationSource"]);
                XCTAssertTrue([body[@"to"] isEqualToString:@"SomeNavigationDestination"]);
            } else if ([type isEqualToString:@"connectivity"]) {
                XCTAssertTrue([body[@"change"] isEqualToString:@"SomeConnectivityStatus"]);
            } else if ([type isEqualToString:@"network"]) {
                XCTAssertTrue([body[@"method"] isEqualToString:@"POST"]);
                XCTAssertTrue([body[@"status_code"] isEqualToString:@"200"]);
                XCTAssertTrue([body[@"url"] isEqualToString:@"www.myservice.com"]);
            } else if ([type isEqualToString:@"manual"]) {
                XCTAssertTrue([body[@"myTelemetryParameter"] isEqualToString:@"itsValue"]);
            }
        }
    }

}

- (void)testTelemetryViewEventScrubbing {
    
    RollbarMutableConfig *config = [[Rollbar configuration] mutableCopy];
    config.telemetry.enabled = YES;
    config.telemetry.viewInputsScrubber.enabled = YES;
    [config.telemetry.viewInputsScrubber addScrubField:@"password"];
    [config.telemetry.viewInputsScrubber addScrubField:@"pin"];
    [Rollbar updateWithConfiguration:config];

    [Rollbar recordViewEventForLevel:RollbarLevel_Debug
                             element:@"password"
                           extraData:@{@"content" : @"My Password"}];
    [Rollbar recordViewEventForLevel:RollbarLevel_Debug
                             element:@"not-password"
                           extraData:@{@"content" : @"My Password"}];

    NSArray *telemetryEvents = [RollbarTelemetry.sharedInstance getAllData];
    
    XCTAssertTrue([@"password" compare:[telemetryEvents[0] valueForKeyPath:@"body.element"]] == NSOrderedSame);
    XCTAssertTrue([@"[scrubbed]" compare:[telemetryEvents[0] valueForKeyPath:@"body.content"]] == NSOrderedSame);

    XCTAssertTrue([@"not-password" compare:[telemetryEvents[1] valueForKeyPath:@"body.element"]] == NSOrderedSame);
    XCTAssertTrue([@"My Password" compare:[telemetryEvents[1] valueForKeyPath:@"body.content"]] == NSOrderedSame);
}

- (void)testRollbarLog {
    
    RollbarMutableConfig *config = [[Rollbar configuration] mutableCopy];
    config.telemetry.enabled = YES;
    config.telemetry.captureLog = YES;
    [Rollbar updateWithConfiguration:config];

    [RollbarTelemetry.sharedInstance clearAllData];
    [NSThread sleepForTimeInterval:2.0f];
    NSNumber *counter = [NSNumber numberWithInt:123];
    RollbarLog(@"Logging with telemetry %@", counter);
    NSArray *telemetryEvents = [RollbarTelemetry.sharedInstance getAllData];
    XCTAssertEqual(telemetryEvents.count, 1);
}

@end
#endif
