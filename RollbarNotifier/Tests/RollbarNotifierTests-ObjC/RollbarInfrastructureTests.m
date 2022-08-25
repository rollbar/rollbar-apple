#import <XCTest/XCTest.h>

@import RollbarNotifier;
@import UnitTesting;

@interface RollbarInfrastructureTests : XCTestCase

@end

@implementation RollbarInfrastructureTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)test1_RollbarInfrastructureNotConfiguredException {
    
//    XCTAssertThrowsSpecificNamed([RollbarInfrastructure sharedInstance].configuration,
//                                 NSException,
//                                 @"RollbarInfrastructureNotConfiguredException",
//                                 @"An RollbarInfrastructureNotConfiguredException is expected!");
//    XCTAssertThrowsSpecificNamed([RollbarInfrastructure sharedInstance].logger,
//                                 NSException,
//                                 @"RollbarInfrastructureNotConfiguredException",
//                                 @"An RollbarInfrastructureNotConfiguredException is expected!");
    
//    XCTAssertThrows([RollbarInfrastructure sharedInstance].configuration,
//                    @"An RollbarInfrastructureNotConfiguredException is expected!"
//                    );
//    XCTAssertThrows([RollbarInfrastructure sharedInstance].logger,
//                    @"An RollbarInfrastructureNotConfiguredException is expected!"
//                    );

    
    [[RollbarInfrastructure sharedInstance] configureWith:[RollbarConfig new]];

    XCTAssertNoThrow([RollbarInfrastructure sharedInstance].configuration,
                     @"An RollbarInfrastructureNotConfiguredException is NOT expected!"
                     );
    XCTAssertNoThrow([RollbarInfrastructure sharedInstance].logger,
                     @"An RollbarInfrastructureNotConfiguredException is NOT expected!"
                     );
}

- (void)test2_Basics {
    
    [RollbarLogger clearSdkDataStore];
    NSArray *items = [RollbarLogger readPayloadsFromSdkTransmittedLog];
    XCTAssertNotNil(items);
    XCTAssertEqual(0, items.count);
    items = [RollbarLogger readPayloadsFromSdkTransmittedLog];
    XCTAssertNotNil(items);
    XCTAssertEqual(0, items.count);
    
    RollbarMutableConfig *config =
    [RollbarMutableConfig mutableConfigWithAccessToken:[RollbarTestHelper getRollbarPayloadsAccessToken]
                                           environment:[RollbarTestHelper getRollbarEnvironment]
    ];
    config.developerOptions.transmit = NO;
    config.developerOptions.logTransmittedPayloads = YES;
    config.loggingOptions.maximumReportsPerMinute = 180;
    [[RollbarInfrastructure sharedInstance] configureWith:config];
    
    [NSThread sleepForTimeInterval:1.0f];
    items = [RollbarLogger readPayloadsFromSdkTransmittedLog];
    XCTAssertNotNil(items);

    [[RollbarInfrastructure sharedInstance].logger log:RollbarLevel_Critical
                                               message:@"RollbarInfrastructure basics test 2!"
                                                  data:nil
                                               context:nil
    ];
    
    [RollbarLogger flushRollbarThread];
    items = [RollbarTestUtil readTransmittedPayloadsAsStrings];
    BOOL wasLogged = NO;
    for (NSString *item in items) {
        if (YES == [item containsString:@"RollbarInfrastructure basics test 2!"]) {
            wasLogged = YES;
            break;
        }
    }
    XCTAssertTrue(YES == wasLogged);

    [RollbarLogger clearSdkDataStore];
    items = [RollbarLogger readPayloadsFromSdkTransmittedLog];
    XCTAssertNotNil(items);
    XCTAssertEqual(0, items.count);
    items = [RollbarLogger readPayloadsFromSdkTransmittedLog];
    XCTAssertNotNil(items);
    XCTAssertEqual(0, items.count);
}

- (void)test3_Live {
    
    [RollbarLogger clearSdkDataStore];
    NSArray *items = [RollbarLogger readPayloadsFromSdkTransmittedLog];
    XCTAssertNotNil(items);
    XCTAssertEqual(0, items.count);
    items = [RollbarLogger readPayloadsFromSdkTransmittedLog];
    XCTAssertNotNil(items);
    XCTAssertEqual(0, items.count);
    
    RollbarMutableConfig *config =
    [RollbarMutableConfig mutableConfigWithAccessToken:[RollbarTestHelper getRollbarPayloadsAccessToken]
                                           environment:[RollbarTestHelper getRollbarEnvironment]];
    config.developerOptions.transmit = YES;
    config.developerOptions.logTransmittedPayloads = YES;
    [[RollbarInfrastructure sharedInstance] configureWith:config];
    
    
    [RollbarLogger flushRollbarThread];
    items = [RollbarTestUtil readTransmittedPayloadsAsStrings];
    XCTAssertNotNil(items);
    
    [[RollbarInfrastructure sharedInstance].logger log:RollbarLevel_Critical
                                               message:@"RollbarInfrastructure basics test 3!"
                                                  data:nil
                                               context:nil
    ];
    [RollbarLogger flushRollbarThread];
    items = [RollbarTestUtil readTransmittedPayloadsAsStrings];
    BOOL wasLogged = NO;
    for (NSString *item in items) {
        if (YES == [item containsString:@"RollbarInfrastructure basics test 3!"]) {
            wasLogged = YES;
            break;
        }
    }
    XCTAssertTrue(YES == wasLogged);

    [RollbarLogger clearSdkDataStore];
    items = [RollbarLogger readPayloadsFromSdkTransmittedLog];
    XCTAssertNotNil(items);
    XCTAssertEqual(0, items.count);
    items = [RollbarLogger readPayloadsFromSdkTransmittedLog];
    XCTAssertNotNil(items);
    XCTAssertEqual(0, items.count);
}

//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
