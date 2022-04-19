#import <XCTest/XCTest.h>
@import RollbarCommon;

@interface RollbarHostingProcessUtilTest : XCTestCase

@end

@implementation RollbarHostingProcessUtilTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testGetHostingProcessName {

    NSString *name = [RollbarHostingProcessUtil getHostingProcessName];
    XCTAssertTrue([name isEqualToString:@"xctest"]);
}

- (void)testGetHostingProcessIdentifier {

    int identifier = [RollbarHostingProcessUtil getHostingProcessIdentifier];
    XCTAssertEqual(identifier, [[NSProcessInfo processInfo] processIdentifier]);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
