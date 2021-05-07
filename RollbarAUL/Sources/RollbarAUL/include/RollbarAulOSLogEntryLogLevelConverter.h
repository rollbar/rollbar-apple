//
//  RollbarAulOSLogEntryLogLevelConverter.h
//  
//
//  Created by Andrey Kornich on 2021-03-24.
//

@import Foundation;

#if __has_include(<oslog/OSLog.h>)
  #include <oslog/OSLog.h>
#endif

#import "RollbarLevel.h"

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(macos(10.15))
API_UNAVAILABLE(ios, tvos, watchos)
/// Rollbar level to/from AUL log level converter
@interface RollbarAulOSLogEntryLogLevelConverter : NSObject

+ (OSLogEntryLogLevel) RollbarLevelToOSLogEntryLogLevel:(RollbarLevel)value
API_AVAILABLE(macos(10.15))
API_UNAVAILABLE(ios, tvos, watchos)
;

+ (RollbarLevel) RollbarLevelFromOSLogEntryLogLevel:(OSLogEntryLogLevel)value
API_AVAILABLE(macos(10.15))
API_UNAVAILABLE(ios, tvos, watchos)
;

+ (NSString *) OSLogEntryLogLevelToString:(OSLogEntryLogLevel)value
API_AVAILABLE(macos(10.15))
API_UNAVAILABLE(ios, tvos, watchos)
;

@end

NS_ASSUME_NONNULL_END
