//
//  RollbarAulLogLevelConverter.h
//  
//
//  Created by Andrey Kornich on 2021-03-24.
//

@import Foundation;
@import OSLog;

#import "RollbarLevel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RollbarAulLogLevelConverter : NSObject

+ (os_log_type_t) RollbarLevelToAulLevel:(RollbarLevel)value;

+ (RollbarLevel) RollbarLevelFromAulLevel:(os_log_type_t)value;

@end

NS_ASSUME_NONNULL_END
