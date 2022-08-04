//
//  RollbarPayloadRepositoryTests.m
//  
//
//  Created by Andrey Kornich on 2022-07-28.
//

#import <XCTest/XCTest.h>
#import "../../Sources/RollbarNotifier/RollbarPayloadRepository.h"

@import UnitTesting;

@interface RollbarPayloadRepositoryTests : XCTestCase

@end

@implementation RollbarPayloadRepositoryTests

- (void)setUp {

    [super setUp];
    
    [RollbarTestUtil deletePayloadsStoreFile];
    XCTAssertFalse([RollbarTestUtil checkPayloadsStoreFileExists]);
}

- (void)tearDown {

    //[RollbarTestUtil deletePayloadsStoreFile];

    [super tearDown];
}

#pragma mark - Destinations unit tests

- (void)testRepoInitialization {
    
    XCTAssertFalse([RollbarTestUtil checkPayloadsStoreFileExists]);
    RollbarPayloadRepository *repo = [RollbarPayloadRepository new];
    XCTAssertTrue([RollbarTestUtil checkPayloadsStoreFileExists]);
    
    XCTAssertFalse([repo checkIfTableExists_Unknown]);
    XCTAssertTrue ([repo checkIfTableExists_Destinations]);
    XCTAssertTrue ([repo checkIfTableExists_Payloads]);
}

- (void)testAddDestination {
    
    RollbarPayloadRepository *repo = [RollbarPayloadRepository new];
    NSDictionary<NSString *, NSString *> *destination =
    [repo addDestinationWithEndpoint:@"EP_001" andAccesToken:@"AT_001"];
        
    XCTAssertTrue([destination.allKeys containsObject:@"id"]);
    XCTAssertTrue([destination.allKeys containsObject:@"endpoint"]);
    XCTAssertTrue([destination.allKeys containsObject:@"access_token"]);
    
    XCTAssertTrue([destination.allValues containsObject:@"EP_001"]);
    XCTAssertTrue([destination.allValues containsObject:@"AT_001"]);

    XCTAssertNotNil(destination[@"id"]);
    XCTAssertTrue([destination[@"endpoint"] isEqualToString:@"EP_001"]);
    XCTAssertTrue([destination[@"access_token"] isEqualToString:@"AT_001"]);
}

- (void)testGetDestination {
    
    RollbarPayloadRepository *repo = [RollbarPayloadRepository new];
    [self insertDestinationMocks:repo];
    
    NSDictionary<NSString *, NSString *> *destination =
    [repo getDestinationWithEndpoint:@"EP_001" andAccesToken:@"AT_001"];
    
    XCTAssertNotNil(destination);
    
    XCTAssertTrue([destination.allKeys containsObject:@"id"]);
    XCTAssertTrue([destination.allKeys containsObject:@"endpoint"]);
    XCTAssertTrue([destination.allKeys containsObject:@"access_token"]);
    
    XCTAssertTrue([destination.allValues containsObject:@"EP_001"]);
    XCTAssertTrue([destination.allValues containsObject:@"AT_001"]);
    
    XCTAssertTrue([destination[@"endpoint"] isEqualToString:@"EP_001"]);
    XCTAssertTrue([destination[@"access_token"] isEqualToString:@"AT_001"]);
}

- (void)testGetDestinationByID {
    
    RollbarPayloadRepository *repo = [RollbarPayloadRepository new];
    [self insertDestinationMocks:repo];
    
    NSDictionary<NSString *, NSString *> *destination =
    [repo getDestinationByID:@"0000000000001"];
    
    XCTAssertNotNil(destination);
    
    XCTAssertTrue([destination.allKeys containsObject:@"id"]);
    XCTAssertTrue([destination.allKeys containsObject:@"endpoint"]);
    XCTAssertTrue([destination.allKeys containsObject:@"access_token"]);
    
    XCTAssertTrue([destination[@"id"] isEqualToString:@"1"]);
    XCTAssertTrue([destination[@"endpoint"] isEqualToString:@"EP_001"]);
    XCTAssertTrue([destination[@"access_token"] isEqualToString:@"AT_001"]);
}

- (void)testGetAllDestinations {
    
    RollbarPayloadRepository *repo = [RollbarPayloadRepository new];
    [repo addDestinationWithEndpoint:@"EP_001" andAccesToken:@"AT_001"];
    [repo addDestinationWithEndpoint:@"EP_001" andAccesToken:@"AT_002"];

    NSArray<NSDictionary<NSString *, NSString *> *> *destinations =
    [repo getAllDestinations];
    
    XCTAssertNotNil(destinations);
    
    XCTAssertEqual(destinations.count, 2);

    for(NSDictionary<NSString *, NSString *> *destination in destinations) {
        
        XCTAssertTrue([destination.allKeys containsObject:@"id"]);
        XCTAssertTrue([destination.allKeys containsObject:@"endpoint"]);
        XCTAssertTrue([destination.allKeys containsObject:@"access_token"]);

        XCTAssertTrue([destination.allValues containsObject:@"EP_001"]);

        XCTAssertTrue([destination[@"endpoint"] isEqualToString:@"EP_001"]);
        XCTAssertTrue([destination[@"access_token"] containsString:@"AT_00"]);
    }
}

- (void)testDestinationRemovals {
    
    RollbarPayloadRepository *repo = [RollbarPayloadRepository new];
    [self insertDestinationMocks:repo];
    
    int removedCount = 0;
    int initialCount = [repo getAllDestinations].count;

    XCTAssertEqual(YES, [repo removeDestinationByID:@"0001"]);
    removedCount++;
    XCTAssertEqual(initialCount - removedCount, [repo getAllDestinations].count);

    XCTAssertEqual(YES, [repo removeDestinationByID:@"0001"]);
    //removedCount++;
    XCTAssertEqual(initialCount - removedCount, [repo getAllDestinations].count);

    XCTAssertEqual(YES, [repo removeDestinationWithEndpoint:@"EP_001" andAccesToken:@"AT_007"]);
    removedCount++;
    XCTAssertEqual(initialCount - removedCount, [repo getAllDestinations].count);

    XCTAssertEqual(YES, [repo removeDestinationWithEndpoint:@"EP_001" andAccesToken:@"AT_007"]);
    //removedCount++;
    XCTAssertEqual(initialCount - removedCount, [repo getAllDestinations].count);

    XCTAssertEqual(YES, [repo removeUnusedDestinations]);
    removedCount = initialCount;
    XCTAssertEqual(initialCount - removedCount, [repo getAllDestinations].count);

    XCTAssertEqual(YES, [repo removeAllDestinations]);
    removedCount = initialCount;
    XCTAssertEqual(initialCount - removedCount, [repo getAllDestinations].count);
}

#pragma mark - Destinations performance tests

- (void)testRepoInitializationPerformance {

    [self measureBlock:^{
        
        RollbarPayloadRepository *repo = [RollbarPayloadRepository new];
    }];
}

- (void)testAddRemoveDestinationPerformance {
    
    RollbarPayloadRepository *repo = [RollbarPayloadRepository new];
    XCTAssertTrue(0 == [repo getAllDestinations].count);

    [self measureBlock:^{
        
        [repo addDestinationWithEndpoint:@"EP_001" andAccesToken:@"AT_001"];

        [repo removeDestinationWithEndpoint:@"EP_001" andAccesToken:@"AT_001"];
    }];
}

- (void)testAddRemoveDestinationByIDPerformance {
    
    RollbarPayloadRepository *repo = [RollbarPayloadRepository new];
    XCTAssertTrue(0 == [repo getAllDestinations].count);
    
    [self measureBlock:^{
        
        NSDictionary *destinationRow = [repo addDestinationWithEndpoint:@"EP_001" andAccesToken:@"AT_001"];
        
        [repo removeDestinationByID:destinationRow[@"id"]];
    }];
}

- (void)testGetDestinationPerformance {
    
    RollbarPayloadRepository *repo = [RollbarPayloadRepository new];
    XCTAssertTrue(0 == [repo getAllDestinations].count);
    [self insertDestinationMocks:repo];
    XCTAssertNotNil([repo getAllDestinations]);
    XCTAssertTrue([repo getAllDestinations].count > 0);
    
    [self measureBlock:^{
        
        id result = [repo getDestinationWithEndpoint:@"EP_001" andAccesToken:@"AT_009"];
    }];
}

- (void)testGetAllDestinationsPerformance {
    
    RollbarPayloadRepository *repo = [RollbarPayloadRepository new];
    XCTAssertTrue(0 == [repo getAllDestinations].count);
    [self insertDestinationMocks:repo];
    
    NSArray __block *result = nil;
    [self measureBlock:^{
        
        result = [repo getAllDestinations];
    }];

    XCTAssertNotNil(result);
    XCTAssertTrue(result.count > 0);
}




#pragma mark - Payloads unit tests

- (void)testTimestamp {
    
    NSDate *cutoffTime = [NSDate date];
    NSNumber *threshold = [NSNumber numberWithInteger:[cutoffTime timeIntervalSince1970]];
    
    RollbarSdkLog(@"*** Removing payloads older than: %@ (%@)",
                  cutoffTime,
                  [NSDate dateWithTimeIntervalSince1970:[threshold integerValue]]
                  );

}

//TODO: implement...

#pragma mark - Payloads performance tests
//TODO: implement...






#pragma mark - mocking helpers

- (void)insertDestinationMocks:(RollbarPayloadRepository *)repo {
    
    [repo addDestinationWithEndpoint:@"EP_001" andAccesToken:@"AT_001"];
    [repo addDestinationWithEndpoint:@"EP_001" andAccesToken:@"AT_002"];
    [repo addDestinationWithEndpoint:@"EP_001" andAccesToken:@"AT_003"];
    [repo addDestinationWithEndpoint:@"EP_001" andAccesToken:@"AT_004"];
    [repo addDestinationWithEndpoint:@"EP_001" andAccesToken:@"AT_005"];
    [repo addDestinationWithEndpoint:@"EP_001" andAccesToken:@"AT_006"];
    [repo addDestinationWithEndpoint:@"EP_001" andAccesToken:@"AT_007"];
    [repo addDestinationWithEndpoint:@"EP_001" andAccesToken:@"AT_008"];
    [repo addDestinationWithEndpoint:@"EP_001" andAccesToken:@"AT_009"];
    [repo addDestinationWithEndpoint:@"EP_001" andAccesToken:@"AT_010"];
    
    [repo addDestinationWithEndpoint:@"EP_002" andAccesToken:@"AT_001"];
    [repo addDestinationWithEndpoint:@"EP_003" andAccesToken:@"AT_001"];
    [repo addDestinationWithEndpoint:@"EP_004" andAccesToken:@"AT_001"];
    [repo addDestinationWithEndpoint:@"EP_005" andAccesToken:@"AT_001"];
}

@end
