//
//  RollbarLoggerRegistry.h
//  
//
//  Created by Andrey Kornich on 2022-06-28.
//

#import <Foundation/Foundation.h>

#import "RollbarConfig.h"
#import "RollbarLogger.h"
#import "RollbarDestinationRecord.h"

NS_ASSUME_NONNULL_BEGIN

@interface RollbarLoggerRegistry : NSObject

- (nonnull RollbarLogger *)loggerWithConfiguration:(nonnull RollbarConfig *)config;
//- (void)unregisterLogger:(nonnull RollbarLogger *)logger;
- (NSUInteger)totalDestinationRecords;
- (NSUInteger)totalLoggerRecords;

+ (nonnull NSString *)destinationID:(nonnull RollbarDestination *)destination;

@end

NS_ASSUME_NONNULL_END
