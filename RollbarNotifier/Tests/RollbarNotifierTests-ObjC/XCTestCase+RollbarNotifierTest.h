//
//  XCTestCase+RollbarNotifierTest.h
//  
//
//  Created by Andrey Kornich on 2022-06-15.
//

#import <XCTest/XCTest.h>

@class RollbarMutableConfig;
@class RollbarPayloadFactory;
@class RollbarPayload;

NS_ASSUME_NONNULL_BEGIN

@interface XCTestCase (RollbarNotifierTest)

- (nonnull RollbarPayloadFactory *)getPayloadFactory_Live_Default;

- (nonnull RollbarMutableConfig*) getConfig_Live_Default;

- (nonnull NSString *)getCrashReportMock;
- (nonnull NSString *)getMessageMock;

- (nonnull RollbarPayload *)getPayload_CrashReport;
- (nonnull RollbarPayload *)getPayload_Message;
- (nonnull RollbarPayload *)getPayload_Error;
- (nonnull RollbarPayload *)getPayload_Exception;

@end

NS_ASSUME_NONNULL_END
