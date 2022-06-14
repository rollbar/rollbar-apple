//
//  RollbarSender.h
//  
//
//  Created by Andrey Kornich on 2022-06-10.
//

#import <Foundation/Foundation.h>

@class RollbarConfig;
@class RollbarPayloadPostReply;

NS_ASSUME_NONNULL_BEGIN

@interface RollbarSender : NSObject

- (nullable RollbarPayloadPostReply *)sendPayload:(nonnull NSData *)payload
                                      usingConfig:(nonnull RollbarConfig  *)config;
@end

NS_ASSUME_NONNULL_END
