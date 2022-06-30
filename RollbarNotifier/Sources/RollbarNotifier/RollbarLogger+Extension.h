//
//  RollbarLogger+Internal.h
//  
//
//  Created by Andrey Kornich on 2022-06-28.
//

#import "RollbarLogger.h"

NS_ASSUME_NONNULL_BEGIN

@interface RollbarLogger ()

#pragma mark - initializers

- (instancetype)initWithConfiguration:(nonnull RollbarConfig *)config
                          andRegistry:(nonnull RollbarLoggerRegistry *)registry
NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
