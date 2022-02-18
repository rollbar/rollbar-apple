//
//  RollbarAulLogLevelConverter.h
//  
//
//  Created by Andrey Kornich on 2021-03-24.
//

#ifndef RollbarAulLogLevelConverter_h
#define RollbarAulLogLevelConverter_h

@import Foundation;

#if TARGET_OS_OSX

@import RollbarNotifier;

#if __has_include(<os/log.h>)
  #include <os/log.h>
#endif

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(macos(10.11), ios(9.0), tvos(9.0), watchos(2.0))
/// Rollbar level to/from AUL log type converter
@interface RollbarAulLogLevelConverter : NSObject

/// Converts a Rollbar log level to a AulLevel
/// @param value a Rollbar log level
+ (os_log_type_t) RollbarLevelToAulLevel:(RollbarLevel)value
API_AVAILABLE(macos(10.11), ios(9.0), tvos(9.0), watchos(2.0))
;

/// Converts an AulLevel to a Rollbar log level
/// @param value an AulLevel
+ (RollbarLevel) RollbarLevelFromAulLevel:(os_log_type_t)value
API_AVAILABLE(macos(10.11), ios(9.0), tvos(9.0), watchos(2.0))
;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarAulLogLevelConverter_h

#endif //TARGET_OS_OSX
