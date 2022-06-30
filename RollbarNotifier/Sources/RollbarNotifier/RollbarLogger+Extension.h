//
//  RollbarLogger+Internal.h
//  
//
//  Created by Andrey Kornich on 2022-06-28.
//

#import "RollbarLogger.h"

@import Foundation;

@class RollbarConfig;
@class RollbarLoggerRecord;

NS_ASSUME_NONNULL_BEGIN

@interface RollbarLogger () {
}

#pragma mark - properties

@property (readonly)RollbarLoggerRecord *loggerRecord;

#pragma mark - initializers

- (instancetype)initWithConfiguration:(nonnull RollbarConfig *)config
                      andLoggerRecord:(nonnull RollbarLoggerRecord *)loggerRecord
NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
