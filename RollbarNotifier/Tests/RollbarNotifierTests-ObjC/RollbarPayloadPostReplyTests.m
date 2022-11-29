//
//  RollbarPayloadPostReplyTests.m
//  
//
//  Created by Andrey Kornich on 2022-06-14.
//

#import <XCTest/XCTest.h>
#import "../../Sources/RollbarNotifier/RollbarPayloadPostReply.h"

@interface RollbarPayloadPostReplyTests : XCTestCase

@end

@implementation RollbarPayloadPostReplyTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testCanPostNowReply {

    RollbarPayloadPostReply *reply = [[RollbarPayloadPostReply alloc] initWithStatusCode:200
                                                                               rateLimit:60
                                                                          remainingCount:10
                                                                        remainingSeconds:20];
    NSDate *now = [NSDate date];
    XCTAssertEqual([now earlierDate:reply.nextPostTime], reply.nextPostTime);
}

- (void)testWillPostLaterReply {
    
    RollbarPayloadPostReply *reply = [[RollbarPayloadPostReply alloc] initWithStatusCode:200
                                                                               rateLimit:60
                                                                          remainingCount:0
                                                                        remainingSeconds:20];
    NSDate *now = [NSDate date];
    XCTAssertEqual([now earlierDate:reply.nextPostTime], now);
    XCTAssertTrue([reply.nextPostTime timeIntervalSinceDate:now] <= 20);
}

- (void)testGreenReply {
    
    RollbarPayloadPostReply *reply = [RollbarPayloadPostReply greenReply];
    NSDate *now = [NSDate date];
    XCTAssertEqual([now earlierDate:reply.nextPostTime], reply.nextPostTime);
}

- (void)testRedReply {
    
    RollbarPayloadPostReply *reply = [RollbarPayloadPostReply redReply];
    NSDate *now = [NSDate date];
    XCTAssertEqual([now earlierDate:reply.nextPostTime], now);
    XCTAssertTrue([reply.nextPostTime timeIntervalSinceDate:now] <= reply.remainingSeconds);
}

- (void)testPerformanceExample {
    
    [self measureBlock:^{
        RollbarPayloadPostReply *reply = [[RollbarPayloadPostReply alloc] initWithStatusCode:200
                                                                                   rateLimit:60
                                                                              remainingCount:10
                                                                            remainingSeconds:20];
    }];
}

@end
