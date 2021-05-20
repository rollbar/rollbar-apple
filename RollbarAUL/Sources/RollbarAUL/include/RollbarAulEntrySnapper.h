//
//  RollbarAulEntrySnapper.h
//  
//
//  Created by Andrey Kornich on 2021-05-03.
//

#ifndef RollbarAulEntrySnapper_h
#define RollbarAulEntrySnapper_h

@import Foundation;

#if TARGET_OS_OSX

//@import OSLog;
#if __has_include(<OSLog/OSLog.h>)
  #include <OSLog/OSLog.h>
#endif

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(macos(10.15))
API_UNAVAILABLE(ios, tvos, watchos)
/// Rollbar class for capturing AUL entries as NSDictionaries
@interface RollbarAulEntrySnapper : NSObject

- (void)captureOSLogEntry:(nullable OSLogEntry *)entry
             intoSnapshot:(nonnull NSMutableDictionary<NSString *, id> *)snapshot
API_AVAILABLE(macos(10.15))
API_UNAVAILABLE(ios, tvos, watchos)
;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarAulEntrySnapper_h

#endif //TARGET_OS_OSX
