//
//  XCTestCase+RollbarNotifierTest.h
//  
//
//  Created by Andrey Kornich on 2022-06-15.
//

#import <XCTest/XCTest.h>

@class RollbarConfig;
@class RollbarPayloadFactory;
@class RollbarPayload;

NS_ASSUME_NONNULL_BEGIN

@interface XCTestCase (RollbarNotifierTest)

- (nonnull RollbarPayloadFactory *)getPayloadFactory_Live_Default;

- (nonnull RollbarConfig*) getConfig_Live_Default;

- (nonnull NSString *)getCrashReport_PLCrashReporter_Symbolicated;
- (nonnull NSString *)getMessageMock;

- (nonnull RollbarPayload *)getPayload_CrashReport;
- (nonnull RollbarPayload *)getPayload_Message;



@end

NS_ASSUME_NONNULL_END
