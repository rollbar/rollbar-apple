//
//  RollbarKSCrashInstallation.h
//  
//
//  Created by Andrey Kornich on 2020-10-28.
//

#ifndef RollbarKSCrashInstallation_h
#define RollbarKSCrashInstallation_h

@import KSCrash_Installations;

NS_ASSUME_NONNULL_BEGIN

/// Rollbar KSCrash installation helper
@interface RollbarKSCrashInstallation : KSCrashInstallation

/// The shared instance of this helper.
+ (instancetype)sharedInstance;

/// Sends all the discovered KSCrash reports.
- (void)sendAllReports;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarKSCrashInstallation_h
