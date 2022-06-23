#import <XCTest/XCTest.h>

@import RollbarNotifier;

@interface RollbarInfrastructureTests : XCTestCase

@end

@implementation RollbarInfrastructureTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testRollbarInfrastructureNotConfiguredException {
    
//    XCTAssertThrowsSpecificNamed([RollbarInfrastructure sharedInstance].configuration,
//                                 NSException,
//                                 @"RollbarInfrastructureNotConfiguredException",
//                                 @"An RollbarInfrastructureNotConfiguredException is expected!");
//    XCTAssertThrowsSpecificNamed([RollbarInfrastructure sharedInstance].logger,
//                                 NSException,
//                                 @"RollbarInfrastructureNotConfiguredException",
//                                 @"An RollbarInfrastructureNotConfiguredException is expected!");
    XCTAssertThrows([RollbarInfrastructure sharedInstance].configuration,
                    @"An RollbarInfrastructureNotConfiguredException is expected!"
                    );
    XCTAssertThrows([RollbarInfrastructure sharedInstance].logger,
                    @"An RollbarInfrastructureNotConfiguredException is expected!"
                    );

    [[RollbarInfrastructure sharedInstance] configureWith:[RollbarConfig new]];

    XCTAssertNoThrow([RollbarInfrastructure sharedInstance].configuration,
                     @"An RollbarInfrastructureNotConfiguredException is NOT expected!"
                     );
    XCTAssertNoThrow([RollbarInfrastructure sharedInstance].logger,
                     @"An RollbarInfrastructureNotConfiguredException is NOT expected!"
                     );
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
