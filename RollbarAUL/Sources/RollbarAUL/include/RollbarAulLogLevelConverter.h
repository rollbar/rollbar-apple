//
//  RollbarAulLogLevelConverter.h
//  
//
//  Created by Andrey Kornich on 2021-03-24.
//

@import Foundation;

#if __has_include(<os/log.h>)
  #include <os/log.h>
#endif

#import "RollbarLevel.h"

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(macos(10.11), ios(9.0), tvos(9.0), watchos(2.0))
@interface RollbarAulLogLevelConverter : NSObject

+ (os_log_type_t) RollbarLevelToAulLevel:(RollbarLevel)value
API_AVAILABLE(macos(10.11), ios(9.0), tvos(9.0), watchos(2.0))
;

+ (RollbarLevel) RollbarLevelFromAulLevel:(os_log_type_t)value
API_AVAILABLE(macos(10.11), ios(9.0), tvos(9.0), watchos(2.0))
;

@end

NS_ASSUME_NONNULL_END
