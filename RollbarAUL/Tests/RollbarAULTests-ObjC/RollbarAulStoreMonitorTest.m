//
//  RollbarAulStoreMonitorTest.m
//  
//
//  Created by Andrey Kornich on 2021-05-03.
//

@import Foundation;
@import OSLog;

#if !TARGET_OS_WATCH
#import <XCTest/XCTest.h>

@import RollbarNotifier;
@import RollbarAUL;

@interface RollbarAulStoreMonitorTest : XCTestCase

@end

@implementation RollbarAulStoreMonitorTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)generateLogEntries {
    
    NSBundle *mainBundle =
    [NSBundle mainBundle];
    
    NSString *bundleIdentifier =
    [mainBundle objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey];

    os_log_t customLog = os_log_create(bundleIdentifier.UTF8String, "test_category");
    int i = 0;
    int maxIterations = 10;
    while (i++ < maxIterations) {
        NSDateFormatter *timestampFormatter = [[NSDateFormatter alloc] init];
        [timestampFormatter setDateFormat:@"YYYY-MM-dd 'at' HH:mm:ss.SSSSSSXX"];
        os_log_error(customLog, "An error occurred at %@!", [timestampFormatter stringFromDate:[NSDate date]]);
        [NSThread sleepForTimeInterval:2.0f];
    }

}

- (void)testRollbarAulStoreMonitor {

    RollbarAulStoreMonitorOptions *aulMonitorOptions =
    [[RollbarAulStoreMonitorOptions alloc] init];
    [aulMonitorOptions addAulCategory:@"test_category"];
    
    [RollbarAulStoreMonitor.sharedInstance configureWithOptions:aulMonitorOptions];
    [RollbarAulStoreMonitor.sharedInstance start];
    
    [self generateLogEntries];
    
    [NSThread sleepForTimeInterval:10.0f];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    //[self measureBlock:^{
        // Put the code you want to measure the time of here.
    //}];
}

@end
#endif
