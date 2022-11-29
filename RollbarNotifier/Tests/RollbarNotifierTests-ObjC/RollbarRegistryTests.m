//
//  RollbarLoggerRegistryTests.m
//  
//
//  Created by Andrey Kornich on 2022-06-30.
//

#import <XCTest/XCTest.h>

@import Foundation;
@import RollbarNotifier;

#import "../../Sources/RollbarNotifier/RollbarRegistry.h"
#import "../../Sources/RollbarNotifier/RollbarDestinationRecord.h"
#import "../../Sources/RollbarNotifier/RollbarPayloadPostReply.h"

@interface RollbarLoggerRegistryTests : XCTestCase

@end

@implementation RollbarLoggerRegistryTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma mark - registry destination record tests

- (void)testDestinationRecord {
    
    RollbarRegistry *registry = [RollbarRegistry new];
    XCTAssertEqual(0, registry.totalDestinationRecords);
    
    RollbarConfig *config = [RollbarConfig mutableConfigWithAccessToken:@"AT1"
                                                     environment:@"Env1"];
    
    RollbarDestinationRecord *record = [registry getRecordForConfig:config];
    XCTAssertEqual(1, registry.totalDestinationRecords);
    XCTAssertEqual(YES, [record canPost]);
    XCTAssertNotNil(record.nextEarliestPost);
    XCTAssertNil(record.nextLocalWindowStart);
    XCTAssertNil(record.nextServerWindowStart);

    RollbarPayloadPostReply *reply = [RollbarPayloadPostReply greenReply];
    [record recordPostReply:reply];
    XCTAssertTrue([record canPost]);
    
    reply = [RollbarPayloadPostReply yellowReply];
    [record recordPostReply:reply];
    XCTAssertFalse([record canPost]);

    reply = [RollbarPayloadPostReply redReply];
    [record recordPostReply:reply];
    XCTAssertFalse([record canPost]);
}

#pragma mark - registry records tests

- (void)testRegistryRecords {
    
    RollbarRegistry *registry = [RollbarRegistry new];
    XCTAssertEqual(0, registry.totalDestinationRecords);
    
    RollbarConfig *config = [RollbarConfig configWithAccessToken:@"AT1"
                                                     environment:@"Env1"];
    
    RollbarDestinationRecord *record = [registry getRecordForConfig:config];
    XCTAssertEqual(1, registry.totalDestinationRecords);
    XCTAssertTrue([record.destinationID containsString:@"https://api.rollbar.com/api/1/item/"]);
    XCTAssertTrue([record.destinationID containsString:@"AT1"]);
    XCTAssertFalse([record.destinationID containsString:@"Env1"]);

    RollbarConfig *config1 = [config copy];
    RollbarDestinationRecord *record1 = [registry getRecordForConfig:config1];
    XCTAssertEqual(1, registry.totalDestinationRecords);
    XCTAssertTrue([record1.destinationID containsString:@"https://api.rollbar.com/api/1/item/"]);
    XCTAssertTrue([record1.destinationID containsString:@"AT1"]);
    XCTAssertFalse([record1.destinationID containsString:@"Env1"]);
    XCTAssertEqualObjects(record, record1);
    XCTAssertEqual(record, record1);
    XCTAssertIdentical(record, record1);
    XCTAssertTrue(record == record1);

    RollbarConfig *config2 = [RollbarConfig configWithAccessToken:@"AT2"
                                                      environment:@"Env2"];
    RollbarDestinationRecord *record2 = [registry getRecordForConfig:config2];
    XCTAssertEqual(2, registry.totalDestinationRecords);
    XCTAssertTrue([record2.destinationID containsString:@"https://api.rollbar.com/api/1/item/"]);
    XCTAssertTrue([record2.destinationID containsString:@"AT2"]);
    XCTAssertFalse([record2.destinationID containsString:@"Env2"]);
    XCTAssertNotEqualObjects(record2, record1);
    XCTAssertNotEqual(record2, record1);
    XCTAssertNotIdentical(record2, record1);
    XCTAssertFalse(record2 == record1);
}

- (void)testPerformanceOfNewDestinationRecord {
    
    RollbarRegistry *registry = [RollbarRegistry new];
    XCTAssertEqual(0, registry.totalDestinationRecords);
    
    RollbarConfig *config = [RollbarConfig configWithAccessToken:@"AT1"
                                                     environment:@"Env1"];
    [self measureBlock:^{
        RollbarDestinationRecord *record = [registry getRecordForConfig:config];
    }];
}

#pragma mark - destination ID tests

- (void)testDestinationID {

    RollbarDestination *destination = [[RollbarDestination alloc] initWithEndpoint:@"End_Point"
                                                                       accessToken:@"Access_Token"
                                                                       environment:@"ENV"
    ];
    
    NSString *destinationID = [RollbarRegistry destinationID:destination];
    XCTAssertTrue([destinationID containsString:@"End_Point"]);
    XCTAssertTrue([destinationID containsString:@"Access_Token"]);
    XCTAssertFalse([destinationID containsString:@"ENV"]);
}

- (void)testPerformanceDestinationID {

    RollbarDestination *destination = [[RollbarDestination alloc] initWithEndpoint:@"End_Point"
                                                                       accessToken:@"Access_Token"
                                                                       environment:@"ENV"
    ];
    [self measureBlock:^{
        NSString *destinationID = [RollbarRegistry destinationID:destination];
    }];
}

@end
