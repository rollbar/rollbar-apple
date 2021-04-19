//
//  RollbarAulOSLogEntryLogLevelConverter.h
//  
//
//  Created by Andrey Kornich on 2021-03-24.
//

@import Foundation;

//@import OSLog;
#if __has_include(<oslog/OSLog.h>)
  #include <oslog/OSLog.h>
#endif

#import "RollbarLevel.h"

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(macos(10.15))
API_UNAVAILABLE(ios, tvos, watchos)
@interface RollbarAulOSLogEntryLogLevelConverter : NSObject

+ (OSLogEntryLogLevel) RollbarLevelToOSLogEntryLogLevel:(RollbarLevel)value;

+ (RollbarLevel) RollbarLevelFromOSLogEntryLogLevel:(OSLogEntryLogLevel)value;

+ (NSString *) OSLogEntryLogLevelToString:(OSLogEntryLogLevel)value;

@end

NS_ASSUME_NONNULL_END
