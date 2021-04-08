//
//  RollbarAulOSLogEntryLogLevelConverter.h
//  
//
//  Created by Andrey Kornich on 2021-03-24.
//

@import Foundation;
@import OSLog;

#import "RollbarLevel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RollbarAulOSLogEntryLogLevelConverter : NSObject

+ (OSLogEntryLogLevel) RollbarLevelToOSLogEntryLogLevel:(RollbarLevel)value
API_AVAILABLE(macos(10.15));

+ (RollbarLevel) RollbarLevelFromOSLogEntryLogLevel:(OSLogEntryLogLevel)value
API_AVAILABLE(macos(10.15));

@end

NS_ASSUME_NONNULL_END
