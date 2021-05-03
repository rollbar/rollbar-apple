//
//  RollbarAulEntrySnapper.h
//  
//
//  Created by Andrey Kornich on 2021-05-03.
//

@import Foundation;
@import OSLog;

NS_ASSUME_NONNULL_BEGIN

@interface RollbarAulEntrySnapper : NSObject

- (void)captureOSLogEntry:(nullable OSLogEntry *)entry
             intoSnapshot:(nonnull NSMutableDictionary<NSString *, id> *)snapshot;

@end

NS_ASSUME_NONNULL_END
