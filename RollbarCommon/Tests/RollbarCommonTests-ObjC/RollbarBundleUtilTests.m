#import <XCTest/XCTest.h>

@import RollbarCommon;

@interface RollbarBundleUtilTests : XCTestCase

@end

@implementation RollbarBundleUtilTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testDetectAppBundleVersion {

    NSString *version  = [RollbarBundleUtil detectAppBundleVersion];
    XCTAssertNotNil(version);
    XCTAssertGreaterThan(version.length, 0);
    XCTAssertGreaterThanOrEqual([version componentsSeparatedByString:@"."].count, 3);
}

- (void)testPerformanceDetectAppBundleVersion {
    // This is an example of a performance test case.
    [self measureBlock:^{

        NSString *version  = [RollbarBundleUtil detectAppBundleVersion];
    }];
}

@end
