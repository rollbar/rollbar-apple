//
//  RollbarLoggerRecord.h
//  
//
//  Created by Andrey Kornich on 2022-06-28.
//

#import <Foundation/Foundation.h>

@class RollbarConfig;
@class RollbarLogger;
@class RollbarDestinationRecord;

NS_ASSUME_NONNULL_BEGIN

@interface RollbarLoggerRecord : NSObject

@property (readonly) BOOL isInScope;
@property (readonly, nonnull) RollbarLogger *logger;
@property (readonly, nonnull) RollbarDestinationRecord *destinationRecord;

- (void)markAsOutOfScope;

- (instancetype)initWithConfig:(nonnull RollbarConfig *)config
          andDestinationRecord:(nonnull RollbarDestinationRecord *)destinationRecord;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
