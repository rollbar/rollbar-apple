//
//  RollbarSenderTests.m
//  
//
//  Created by Andrey Kornich on 2022-06-14.
//

#import <XCTest/XCTest.h>
#import "XCTestCase+RollbarNotifierTest.h"

#import "../../Sources/RollbarNotifier/RollbarSender.h"
#import "../../Sources/RollbarNotifier/RollbarPayloadFactory.h"

@import RollbarNotifier;

@interface RollbarSenderTests : XCTestCase

@end

@implementation RollbarSenderTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testSendingCrashReport {

    RollbarPayload *payload =[self getPayload_CrashReport];
    NSData *payloadData = [payload serializeToJSONData];
    RollbarSender *sender = [RollbarSender new];
    RollbarPayloadPostReply *reply = [sender sendPayload:payloadData usingConfig:[self getConfig_Live_Default]];
    
    XCTAssertNotNil(reply);
}

- (void)testPerformanceSendingCrashReport {
    
    RollbarPayload *payload =[self getPayload_CrashReport];
    NSData *payloadData = [payload serializeToJSONData];
    RollbarSender *sender = [RollbarSender new];
    
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        RollbarPayloadPostReply *reply = [sender sendPayload:payloadData usingConfig:[self getConfig_Live_Default]];
    }];
}

- (void)testSendingMessage {
    
    RollbarPayload *payload =[self getPayload_Message];
    NSData *payloadData = [payload serializeToJSONData];
    RollbarSender *sender = [RollbarSender new];
    RollbarPayloadPostReply *reply = [sender sendPayload:payloadData usingConfig:[self getConfig_Live_Default]];
    
    XCTAssertNotNil(reply);
}

- (void)testPerformanceSendingMessage {
    
    RollbarPayload *payload =[self getPayload_Message];
    NSData *payloadData = [payload serializeToJSONData];
    RollbarSender *sender = [RollbarSender new];
    
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        RollbarPayloadPostReply *reply = [sender sendPayload:payloadData usingConfig:[self getConfig_Live_Default]];
    }];
}

- (void)testSendingError {

//TODO: implement...
//    RollbarPayload *payload =[self getPayload_Message];
//    NSData *payloadData = [payload serializeToJSONData];
//    RollbarSender *sender = [RollbarSender new];
//    RollbarPayloadPostReply *reply = [sender sendPayload:payloadData usingConfig:[self getConfig_Live_Default]];
//
//    XCTAssertNotNil(reply);
}

- (void)testPerformanceSendingError {
    
    //TODO: implement...
//    RollbarPayload *payload =[self getPayload_Message];
//    NSData *payloadData = [payload serializeToJSONData];
//    RollbarSender *sender = [RollbarSender new];
//
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//        RollbarPayloadPostReply *reply = [sender sendPayload:payloadData usingConfig:[self getConfig_Live_Default]];
//    }];
}

- (void)testSendingException {
    
    //TODO: implement...
    //    RollbarPayload *payload =[self getPayload_Message];
    //    NSData *payloadData = [payload serializeToJSONData];
    //    RollbarSender *sender = [RollbarSender new];
    //    RollbarPayloadPostReply *reply = [sender sendPayload:payloadData usingConfig:[self getConfig_Live_Default]];
    //
    //    XCTAssertNotNil(reply);
}

- (void)testPerformanceSendingException {
    
    //TODO: implement...
    //    RollbarPayload *payload =[self getPayload_Message];
    //    NSData *payloadData = [payload serializeToJSONData];
    //    RollbarSender *sender = [RollbarSender new];
    //
    //    [self measureBlock:^{
    //        // Put the code you want to measure the time of here.
    //        RollbarPayloadPostReply *reply = [sender sendPayload:payloadData usingConfig:[self getConfig_Live_Default]];
    //    }];
}

- (void)testPerformanceRollbarSenderInstantiation{

    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        RollbarSender *sender = [RollbarSender new];
    }];
}

@end
