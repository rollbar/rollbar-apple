//
//  RollbarPayloadPostReply.h
//  
//
//  Created by Andrey Kornich on 2022-06-13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RollbarPayloadPostReply : NSObject

@property (readonly) NSInteger statusCode;
@property (readonly) NSUInteger rateLimit;
@property (readonly) NSUInteger remainingCount;
@property (readonly) NSUInteger remainingSeconds;
@property (readonly) NSDate *nextPostTime;

- (instancetype)initWithStatusCode:(NSUInteger)statusCode
                         rateLimit:(NSUInteger)rateLimit
                    remainingCount:(NSUInteger)remainingCount
                  remainingSeconds:(NSUInteger)remainingSeconds;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (nullable RollbarPayloadPostReply *)replyFromHttpResponse:(nonnull NSHTTPURLResponse *)httpResponse;
+ (nonnull RollbarPayloadPostReply *)greenReply;
+ (nonnull RollbarPayloadPostReply *)yellowReply;
+ (nonnull RollbarPayloadPostReply *)redReply;

@end

NS_ASSUME_NONNULL_END
