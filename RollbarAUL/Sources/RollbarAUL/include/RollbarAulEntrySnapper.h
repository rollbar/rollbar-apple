//
//  RollbarAulEntrySnapper.h
//  
//
//  Created by Andrey Kornich on 2021-05-03.
//

@import Foundation;

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
             intoSnapshot:(nonnull NSMutableDictionary<NSString *, id> *)snapshot;

@end

NS_ASSUME_NONNULL_END
