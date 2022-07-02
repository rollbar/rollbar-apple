//
//  RollbarLoggerRegistryRecord.h
//  
//
//  Created by Andrey Kornich on 2022-06-28.
//

#import <Foundation/Foundation.h>

@class RollbarConfig;
@class RollbarLoggerRecord;
@class RollbarLoggerRegistry;
@class RollbarLogger;

NS_ASSUME_NONNULL_BEGIN

@interface RollbarLoggerRegistryRecord : NSObject

@property (readonly, nonnull) NSString *destinationID;
@property (readonly, nonnull) NSSet<RollbarLoggerRecord *> *loggerRecords;
@property (readonly, nonnull) RollbarLoggerRegistry *registry;

- (nonnull RollbarLogger *)addLoggerWithConfig:(nonnull RollbarConfig *)loggerConfig;
//- (void)removeLogger:(nonnull RollbarLogger *)logger;
- (void)removeLoggerRecord:(nonnull RollbarLoggerRecord *)loggerRecord;
- (NSUInteger)totalLoggerRecords;


- (instancetype)initWithDestinationID:(nonnull NSString *)destinationID
                          andRegistry:(RollbarLoggerRegistry *)registry
NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
