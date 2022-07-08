//
//  RollbarDestinationRecord.h
//  
//
//  Created by Andrey Kornich on 2022-06-28.
//

#import <Foundation/Foundation.h>

@class RollbarConfig;
@class RollbarRegistry;

NS_ASSUME_NONNULL_BEGIN

@interface RollbarDestinationRecord : NSObject

@property (readonly, nonnull) NSString *destinationID;
@property (readonly, nonnull) RollbarRegistry *registry;

- (instancetype)initWithDestinationID:(nonnull NSString *)destinationID
                          andRegistry:(nonnull RollbarRegistry *)registry
NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
