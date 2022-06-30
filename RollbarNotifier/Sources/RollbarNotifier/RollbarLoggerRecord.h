//
//  RollbarLoggerRecord.h
//  
//
//  Created by Andrey Kornich on 2022-06-28.
//

#import <Foundation/Foundation.h>

@class RollbarConfig;
@class RollbarLogger;
@class RollbarLoggerRegistryRecord;

NS_ASSUME_NONNULL_BEGIN

@interface RollbarLoggerRecord : NSObject

@property (readonly, nonnull) RollbarLogger *logger;
@property (readonly, nonnull) RollbarLoggerRegistryRecord *registryRecord;

- (instancetype)initWithConfig:(nonnull RollbarConfig *)config
             andRegistryRecord:(nonnull RollbarLoggerRegistryRecord *)registryRecord;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
