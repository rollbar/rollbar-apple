#import <XCTest/XCTest.h>

@import RollbarCommon;

@interface NSDate_RollbarTests : XCTestCase

@end

@implementation NSDate_RollbarTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testDateToString {
    
    if (@available(tvOS 13.0, *)) {
        NSString *dateString = [[NSDate now] rollbar_toString];
        XCTAssertNotNil(dateString);
        XCTAssertTrue(dateString.length > 0);
    } else {
        // Fallback on earlier versions
    }
}

- (void)testDateFromString {

    NSDate *date = [NSDate rollbar_dateFromString:@"2022-04-28 at 14:49:29.560000-0700"];
    XCTAssertNotNil(date);
}

- (void)testPerformanceDateToString {

    [self measureBlock:^{
        
        if (@available(tvOS 13.0, *)) {
            NSString *dateString = [[NSDate now] rollbar_toString];
        } else {
            // Fallback on earlier versions
        }
    }];
}

- (void)testPerformanceDateFromString {
    
    [self measureBlock:^{
        
        NSDate *date = [NSDate rollbar_dateFromString:@"2022-04-28 at 14:49:29.560000-0700"];
    }];
}

@end
