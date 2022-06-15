//
//  RollbarPayloadFactoryTests.m
//  
//
//  Created by Andrey Kornich on 2022-06-15.
//

#import <XCTest/XCTest.h>
#import "../../Sources/RollbarNotifier/RollbarPayloadFactory.h"

@import UnitTesting;
@import RollbarNotifier;

@interface RollbarPayloadFactoryTests : XCTestCase

@end

@implementation RollbarPayloadFactoryTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testCrashReportPayload {

    NSString *crashReport = @"Fake crash report!";
    RollbarPayload *payload = [[self getPayloadFactory] payloadWithLevel:RollbarLevel_Critical
                                                             crashReport:crashReport];
    
    [self assertCommonComponentsOfPayload:payload];
    
    XCTAssertNotNil(payload.data.body.crashReport);
    XCTAssertNil(payload.data.body.trace);
    XCTAssertNil(payload.data.body.traceChain);
    XCTAssertNil(payload.data.body.message);
    
    XCTAssertTrue([payload.data.body.crashReport.rawCrashReport containsString:crashReport]);
    XCTAssertTrue([[payload serializeToJSONString] containsString:crashReport]);
}

- (void)testMessagePayload {
    
    NSString *message = @"MessageMock";
    RollbarPayload *payload = [[self getPayloadFactory] payloadWithLevel:RollbarLevel_Critical
                                                                   message:message
                                                                    data:nil
                                                                 context:@"MockContext"];
    
    [self assertCommonComponentsOfPayload:payload];
    
    XCTAssertNil(payload.data.body.crashReport);
    XCTAssertNil(payload.data.body.trace);
    XCTAssertNil(payload.data.body.traceChain);
    XCTAssertNotNil(payload.data.body.message);
    
    XCTAssertTrue([payload.data.body.message.description containsString:message]);
    XCTAssertTrue([[payload serializeToJSONString] containsString:message]);
    XCTAssertTrue([[payload serializeToJSONString] containsString:@"MockContext"]);
}


- (void)testErrorPayload {
    
    NSError *error = [NSError errorWithDomain:@"NSErrorDomain" code:1001 userInfo:nil];
    RollbarPayload *payload = [[self getPayloadFactory] payloadWithLevel:RollbarLevel_Critical
                                                                   error:error
                                                                    data:nil
                                                                 context:@"MockContext"];
    
    [self assertCommonComponentsOfPayload:payload];
    
    XCTAssertNil(payload.data.body.crashReport);
    XCTAssertNil(payload.data.body.trace);
    XCTAssertNil(payload.data.body.traceChain);
    XCTAssertNotNil(payload.data.body.message);
    
    XCTAssertTrue([payload.data.body.message.description containsString:@"NSErrorDomain"]);
    XCTAssertTrue([payload.data.body.message.description containsString:@"1001"]);
    XCTAssertTrue([[payload serializeToJSONString] containsString:@"NSErrorDomain"]);
    XCTAssertTrue([[payload serializeToJSONString] containsString:@"1001"]);
    XCTAssertTrue([[payload serializeToJSONString] containsString:@"MockContext"]);
}

- (void)testExceptionPayload {
    
    NSException *exception = [NSException exceptionWithName:@"Oy vey!" reason:@"Don't ask!" userInfo:nil];
    RollbarPayload *payload = [[self getPayloadFactory] payloadWithLevel:RollbarLevel_Critical
                                                               exception:exception
                                                                    data:nil
                                                                 context:@"MockContext"];
    
    [self assertCommonComponentsOfPayload:payload];
    
    XCTAssertNil(payload.data.body.crashReport);
    XCTAssertNotNil(payload.data.body.trace);
    XCTAssertNil(payload.data.body.traceChain);
    XCTAssertNil(payload.data.body.message);
    
    XCTAssertTrue([[payload serializeToJSONString] containsString:@"NSException"]);
    XCTAssertTrue([[payload serializeToJSONString] containsString:@"Don't ask!"]);
    XCTAssertTrue([[payload serializeToJSONString] containsString:@"MockContext"]);
}

- (void)testPerformanceCrashReportPayload {

    NSString *crashReport = @"Fake crash report!";

    [self measureBlock:^{

        RollbarPayload *payload = [[self getPayloadFactory] payloadWithLevel:RollbarLevel_Critical
                                                                 crashReport:crashReport];
        [payload serializeToJSONString];
    }];
}

- (void)testPerformanceMessagePayload {
    
    NSString *message = @"MessageMock";

    [self measureBlock:^{

        RollbarPayload *payload = [[self getPayloadFactory] payloadWithLevel:RollbarLevel_Critical
                                                                     message:message
                                                                        data:nil
                                                                     context:@"MockContext"];
        [payload serializeToJSONString];
    }];
}

- (void)testPerformanceErrorPayload {
    
    NSError *error = [NSError errorWithDomain:@"NSErrorDomain" code:1001 userInfo:nil];

    [self measureBlock:^{

        RollbarPayload *payload = [[self getPayloadFactory] payloadWithLevel:RollbarLevel_Critical
                                                                       error:error
                                                                        data:nil
                                                                     context:@"MockContext"];
        [payload serializeToJSONString];
    }];
}

- (void)testPerformanceExceptionPayload {
    
    NSException *exception = [NSException exceptionWithName:@"Oy vey!" reason:@"Don't ask!" userInfo:nil];

    [self measureBlock:^{
        
        RollbarPayload *payload = [[self getPayloadFactory] payloadWithLevel:RollbarLevel_Critical
                                                                   exception:exception
                                                                        data:nil
                                                                     context:@"MockContext"];
        [payload serializeToJSONString];
    }];
}

- (void)assertCommonComponentsOfPayload:(nullable RollbarPayload *)payload {
    
    XCTAssertNotNil(payload);
    XCTAssertNotNil(payload.data);
    XCTAssertNotNil(payload.data.body);
    XCTAssertNotNil(payload.data.notifier);
    //TODO: continue asserting presence and values of other expected common components of every payload...
}

- (nonnull RollbarPayloadFactory *)getPayloadFactory {
    
    RollbarPayloadFactory *factory = [RollbarPayloadFactory factoryWithConfig:[self getConfig]];
    return factory;
}

- (nonnull RollbarConfig*) getConfig {
    
    RollbarConfig *config =
    [RollbarConfig configWithAccessToken:[RollbarTestHelper getRollbarPayloadsAccessToken]
                             environment:[RollbarTestHelper getRollbarEnvironment]];
    
    return config;
}

@end
