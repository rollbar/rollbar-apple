#import <XCTest/XCTest.h>

#define LOG_LEVEL_DEF ddLogLevel

@import CocoaLumberjack;
@import RollbarNotifier;
@import UnitTesting;

@import RollbarCocoaLumberjack;

static const DDLogLevel ddLogLevel = DDLogLevelDebug;

@interface RollbarCocoaLumberjackTests : XCTestCase
@end

@implementation RollbarCocoaLumberjackTests

- (void)setUp {

    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSLog(@"Set to go...");
    
    [RollbarLogger clearSdkDataStore];
    
    [DDLog addLogger:[DDOSLogger sharedInstance]];
    
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 1;
    // he above code tells the application to keep a day worth of log files on the system.
    
    [DDLog addLogger:fileLogger];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    NSLog(@"Teared down.");
}

- (void)testLiveRollbarCocoaLumberjackBasics {
    
    
    DDLogError(@"Broken sprocket detected!");
    DDLogVerbose(@"User selected file:%@ withSize:%u", @"somewhere/file.ext", 100);
    
    RollbarConfig *config = [[RollbarConfig alloc] init];
    config.destination.accessToken = [RollbarTestHelper getRollbarPayloadsAccessToken];
    config.destination.environment = [RollbarTestHelper getRollbarEnvironment];
    config.developerOptions.transmit = YES;
    config.developerOptions.logPayload = YES;
    config.loggingOptions.maximumReportsPerMinute = 5000;
    
    [DDLog addLogger:[RollbarCocoaLumberjackLogger createWithRollbarConfig:config]];

    DDLogDebug(@"*** Via CocoaLumberjack!!!");

    [NSThread sleepForTimeInterval:5.0f];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

