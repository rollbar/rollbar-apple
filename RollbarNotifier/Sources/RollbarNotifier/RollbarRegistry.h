//
//  RollbarRegistry.h
//  
//
//  Created by Andrey Kornich on 2022-06-28.
//

#import <Foundation/Foundation.h>

#import "RollbarDestinationRecord.h"
#import "RollbarConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface RollbarRegistry : NSObject

- (nonnull RollbarDestinationRecord *)getRecordForConfig:(nonnull RollbarConfig *)config;
- (nonnull RollbarDestinationRecord *)getRecordForEndpoint:(nonnull NSString *)endpoint
                                            andAccessToken:(nonnull NSString *)accessToken;
- (NSUInteger)totalDestinationRecords;

+ (nonnull NSString *)destinationID:(nonnull RollbarDestination *)destination;
+ (nonnull NSString *)destinationIDwithEndpoint:(nonnull NSString *)endpoint
                                 andAccessToken:(nonnull NSString *)accessToken;

@end

NS_ASSUME_NONNULL_END
