//
//  RollbarAulLogLevelConverter.h
//  
//
//  Created by Andrey Kornich on 2021-03-24.
//

@import Foundation;

//@import OSLog;
//#if MAC_OS_X_VERSION_MIN_REQUIRED >= __IPHONE_6_0 //or 90000 // ios(9.0) and above
//@import OSLog;
//#endif
//#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0 //or 90000 // ios(9.0) and above
//@import OSLog;
//#endif
#if __has_include(<os/log.h>)
  #include <os/log.h>
#endif

#import "RollbarLevel.h"

NS_ASSUME_NONNULL_BEGIN

//API_AVAILABLE(macos(10.15))
//API_UNAVAILABLE(ios, tvos, watchos)
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
