@import Foundation;
@import UnitTesting;

#if !TARGET_OS_WATCH
#import <XCTest/XCTest.h>

@import RollbarNotifier;

@interface RollbarTests : XCTestCase

@end

@implementation RollbarTests

- (void)setUp {
    
    [super setUp];

    [RollbarLogger clearSdkDataStore];

    RollbarMutableConfig *config = [[RollbarMutableConfig alloc] init];
    config.destination.accessToken = [RollbarTestHelper getRollbarPayloadsAccessToken];
    config.destination.environment = [RollbarTestHelper getRollbarEnvironment];
    config.developerOptions.transmit = YES;
    config.developerOptions.logPayload = YES;
    config.loggingOptions.maximumReportsPerMinute = 5000;
    // for the stress test specifically:
    config.telemetry.enabled = YES;
    config.loggingOptions.captureIp = RollbarCaptureIpType_Full;
    NSLog(@"%@", config)
    
    [Rollbar initWithConfiguration:config];
}

- (void)tearDown {
    
    [Rollbar updateConfiguration:[RollbarConfig new]];
    [super tearDown];
}

- (void)testMultithreadedStressCase {
    
    for( int i = 0; i < 20; i++) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY,0), ^(){
            RollbarMutableConfig *config = [Rollbar.configuration mutableCopy];
            config.destination.environment = [RollbarTestHelper getRollbarEnvironment];
            RollbarLogger *logger = [[RollbarLogger alloc] initWithConfiguration:config];
            for (int j = 0; j < 20; j++) {
                [logger log:RollbarLevel_Error
                    message:@"error"
                       data:nil
                    context:[NSString stringWithFormat:@"%d-%d", i, j]
                 ];
                //DO NOT CALL THE SHARED INSTANCE ON EXTRA THREADS:
                //[Rollbar errorMessage:@"error"];
            }
        });
    }
    
    [NSThread sleepForTimeInterval:40.0f];
    XCTAssertTrue(YES);
}

- (void)testRollbarNotifiersIndependentConfiguration {

    RollbarMutableConfig *config = [[RollbarMutableConfig alloc] init];

    config.developerOptions.transmit = NO;
    config.developerOptions.logPayload = YES;

    // configure the root notifier:
    config.destination.accessToken = @"AT_0";
    config.destination.environment = @"ENV_0";
    
    [Rollbar updateConfiguration:config];
    
    XCTAssertTrue([[Rollbar configuration].destination.accessToken
                   isEqualToString:config.destination.accessToken]);
    XCTAssertTrue([[Rollbar configuration].destination.environment
                   isEqualToString:config.destination.environment]);
    
    // create and configure another notifier:
    config = [RollbarMutableConfig new];
    config.destination.accessToken = @"AT_1";
    config.destination.environment = @"ENV_1";
    RollbarLogger *notifier = [[RollbarLogger alloc] initWithConfiguration:config];
    XCTAssertTrue([notifier.configuration.destination.accessToken
                   isEqualToString:@"AT_1"]);
    XCTAssertTrue([notifier.configuration.destination.environment
                   isEqualToString:@"ENV_1"]);

    // reconfigure the root notifier:
    config = [[Rollbar configuration] mutableCopy];
    config.destination.accessToken = @"AT_N";
    config.destination.environment = @"ENV_N";
    [Rollbar updateConfiguration:config];
    XCTAssertTrue([[RollbarInfrastructure sharedInstance].logger.configuration.destination.accessToken
                   isEqualToString:@"AT_N"]);
    XCTAssertTrue([[RollbarInfrastructure sharedInstance].logger.configuration.destination.environment
                   isEqualToString:@"ENV_N"]);

    // make sure the other notifier is still has its original configuration:
    XCTAssertTrue([notifier.configuration.destination.accessToken
                   isEqualToString:@"AT_1"]);
    XCTAssertTrue([notifier.configuration.destination.environment
                   isEqualToString:@"ENV_1"]);

    //TODO: to make this test even more valuable we need to make sure the other notifier's payloads
    //      are actually sent to its intended destination. But that is something we will be able to do
    //      once we add to this SDK a feature similar to Rollbar.NET's Internal Events...
}

- (void)testRollbarTransmit {

    RollbarMutableConfig *config = [[Rollbar configuration] mutableCopy];
    
    config.destination.accessToken = @"09da180aba21479e9ed3d91e0b8d58d6";
    config.destination.environment = [RollbarTestHelper getRollbarEnvironment];
    config.developerOptions.transmit = YES;

    config.developerOptions.transmit = YES;
    [Rollbar updateConfiguration:config];
    [Rollbar criticalMessage:@"Transmission test YES"];
    [NSThread sleepForTimeInterval:2.0f];

    config.developerOptions.transmit = NO;
    [Rollbar updateConfiguration:config];
    [Rollbar criticalMessage:@"Transmission test NO"];
    [NSThread sleepForTimeInterval:2.0f];

    config.developerOptions.transmit = YES;
    //config.enabled = NO;
    [Rollbar updateConfiguration:config];
    [Rollbar criticalMessage:@"Transmission test YES2"];
    [NSThread sleepForTimeInterval:2.0f];
    
    int count = 50;
    while (count > 0) {
        [Rollbar criticalMessage:[NSString stringWithFormat: @"Rate Limit Test %i", count]];
         
        [NSThread sleepForTimeInterval:1.0f];
        
        count--;
    }
}

- (void)testNotification {
    
    NSDictionary *notificationText = @{
                                       @"error": @[@"testing-error-with-message"],
                                       @"debug": @[@"testing-debug"],
                                       @"info": @[@"testing-info"],
                                       @"critical": @[@"testing-critical"]
                                       };
    
    for (NSString *type in notificationText.allKeys) {
        NSArray *params = notificationText[type];
        if ([type isEqualToString:@"error"]) {
            [Rollbar errorMessage:params[0]];
        } else if ([type isEqualToString:@"debug"]) {
            [Rollbar debugMessage:params[0]];
        } else if ([type isEqualToString:@"info"]) {
            [Rollbar infoMessage:params[0]];
        } else if ([type isEqualToString:@"critical"]) {
            [Rollbar criticalMessage:params[0]];
        }
    }

    [NSThread sleepForTimeInterval:3.0f];

    NSArray *items = [RollbarLogger readLogItemsFromStore];
    for (id item in items) {
        NSString *level = [item valueForKeyPath:@"level"];
        NSString *message = [item valueForKeyPath:@"body.message.body"];
        NSArray *params = notificationText[level];
        XCTAssertTrue([params[0] isEqualToString:message], @"Expects '%@', got '%@'.", params[0], message);
    }
}

@end
#endif
