//
//  RollbarPayloadFactory.h
//  
//
//  Created by Andrey Kornich on 2022-06-14.
//

#import <Foundation/Foundation.h>

#import "RollbarLevel.h"

@class RollbarConfig;
@class RollbarPayload;

NS_ASSUME_NONNULL_BEGIN

@interface RollbarPayloadFactory : NSObject

- (nullable RollbarPayload *)payloadWithLevel:(RollbarLevel)level
                                  crashReport:(nonnull NSString *)crashReport;

- (nullable RollbarPayload *)payloadWithLevel:(RollbarLevel)level
                                      message:(nonnull NSString *)message
                                         data:(nullable NSDictionary<NSString *, id> *)data
                                      context:(nullable NSString *)context;

- (nullable RollbarPayload *)payloadWithLevel:(RollbarLevel)level
                                    exception:(nonnull NSException *)exception
                                         data:(nullable NSDictionary<NSString *, id> *)data
                                      context:(nullable NSString *)context;

- (nullable RollbarPayload *)payloadWithLevel:(RollbarLevel)level
                                        error:(nonnull NSError *)error
                                         data:(nullable NSDictionary<NSString *, id> *)data
                                      context:(nullable NSString *)context;

- (instancetype)initWithConfig:(nonnull RollbarConfig *)config NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)factoryWithConfig:(nonnull RollbarConfig *)config;

@end

NS_ASSUME_NONNULL_END
