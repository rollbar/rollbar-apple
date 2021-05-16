//
//  RollbarAulLogLevelConverter.h
//  
//
//  Created by Andrey Kornich on 2021-03-24.
//

#ifndef RollbarAulLogLevelConverter_h
#define RollbarAulLogLevelConverter_h

@import Foundation;

#if __has_include(<os/log.h>)
  #include <os/log.h>
#endif

#import "RollbarLevel.h"

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(macos(10.11), ios(9.0), tvos(9.0), watchos(2.0))
/// Rollbar level to/from AUL log type converter
@interface RollbarAulLogLevelConverter : NSObject

+ (os_log_type_t) RollbarLevelToAulLevel:(RollbarLevel)value
API_AVAILABLE(macos(10.11), ios(9.0), tvos(9.0), watchos(2.0))
;

+ (RollbarLevel) RollbarLevelFromAulLevel:(os_log_type_t)value
API_AVAILABLE(macos(10.11), ios(9.0), tvos(9.0), watchos(2.0))
;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarAulLogLevelConverter_h
