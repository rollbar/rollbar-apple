//
//  RollbarDestinationRecord.h
//  
//
//  Created by Andrey Kornich on 2022-06-28.
//

#import <Foundation/Foundation.h>

#import "RollbarConfig.h"
#import "RollbarPayloadPostReply.h"

@class RollbarRegistry;

NS_ASSUME_NONNULL_BEGIN

@interface RollbarDestinationRecord : NSObject

@property (readonly, nonnull) NSString *destinationID;

@property (readwrite) NSUInteger localWindowLimit;

@property (readonly) NSUInteger localWindowCount;
@property (readonly) NSUInteger serverWindowCount;
@property (readonly, nullable) NSDate *nextLocalWindowStart;
@property (readonly, nullable) NSDate *nextServerWindowStart;

@property (readonly, nonnull) RollbarRegistry *registry;

- (BOOL)canPost;
- (void)recordPostReply:(nullable RollbarPayloadPostReply *)reply;

- (instancetype)initWithConfig:(nonnull RollbarConfig *)config
                   andRegistry:(nonnull RollbarRegistry *)registry
NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithDestinationID:(nonnull NSString *)destinationID
                          andRegistry:(nonnull RollbarRegistry *)registry
NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
