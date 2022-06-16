//
//  XCTestCase+RollbarNotifierTest.m
//  
//
//  Created by Andrey Kornich on 2022-06-15.
//

#import "XCTestCase+RollbarNotifierTest.h"
#import "TestData/CrashReports.h"

#import "../../Sources/RollbarNotifier/RollbarPayloadFactory.h"

@import RollbarNotifier;
@import UnitTesting;

@implementation XCTestCase (RollbarNotifierTest)

- (nonnull RollbarPayloadFactory *)getPayloadFactory_Live_Default {
    
    RollbarPayloadFactory *factory = [RollbarPayloadFactory factoryWithConfig:[self getConfig_Live_Default]];
    return factory;
}

- (nonnull RollbarConfig*) getConfig_Live_Default {
    
    RollbarConfig *config =
    [RollbarConfig configWithAccessToken:[RollbarTestHelper getRollbarPayloadsAccessToken]
                             environment:[RollbarTestHelper getRollbarEnvironment]];
    
    return config;
}

- (nonnull NSString *)getContextMock {
    
    return @"Unit test context mock...";
}

- (nonnull NSDictionary<NSString *, id> *)getDataMock {
    
    return @{
        @"data1": @"data 1",
        @"data2": @200,
    };
}

- (nonnull NSString *)getCrashReport_PLCrashReporter_Symbolicated {
    
    return CRASH_REPORT_PLCRASH_SYMBOLICATED;
}

- (nonnull NSString *)getMessageMock {
    
    return @"Unit test message mock...";
}


- (nonnull RollbarPayload *)getPayload_CrashReport {
    
    RollbarPayload *payload =
    [[self getPayloadFactory_Live_Default] payloadWithLevel:RollbarLevel_Critical
                                                crashReport:[self getCrashReport_PLCrashReporter_Symbolicated]];
    return payload;
}

- (nonnull RollbarPayload *)getPayload_Message {
    
    RollbarPayload *payload =
    [[self getPayloadFactory_Live_Default] payloadWithLevel:RollbarLevel_Warning
                                                    message:[self getMessageMock]
                                                       data:[self getDataMock]
                                                    context:[self getContextMock]
    ];
    return payload;
}

@end
