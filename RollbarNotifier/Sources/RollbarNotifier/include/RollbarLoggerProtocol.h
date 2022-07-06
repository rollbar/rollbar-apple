//
//  RollbarLoggerProtocol.h
//  
//
//  Created by Andrey Kornich on 2022-07-06.
//

#ifndef RollbarLoggerProtocol_h
#define RollbarLoggerProtocol_h

@protocol RollbarLogger

#pragma mark - properties

/// Notifier's config object
@property (nullable, atomic, strong) RollbarConfig *configuration;

#pragma mark - logging methods

/// Captures a crash report
/// @param crashReport the crash report
- (void)logCrashReport:(nonnull NSString *)crashReport;

/// Captures a log entry
/// @param level Rollbar error/log level
/// @param message message
/// @param data extra data
/// @param context extra context
- (void)log:(RollbarLevel)level
    message:(nonnull NSString *)message
       data:(nullable NSDictionary<NSString *, id> *)data
    context:(nullable NSString *)context;

/// Captures a log entry
/// @param level Rollbar error/log level
/// @param exception exception
/// @param data extra data
/// @param context extra context
- (void)log:(RollbarLevel)level
  exception:(nonnull NSException *)exception
       data:(nullable NSDictionary<NSString *, id> *)data
    context:(nullable NSString *)context;

/// Capture a log entry based on an NSError
/// @param level Rollbar error/log level
/// @param error an NSError
/// @param data extra data
/// @param context extra context
- (void)log:(RollbarLevel)level
      error:(nonnull NSError *)error
       data:(nullable NSDictionary<NSString *, id> *)data
    context:(nullable NSString *)context;


@end

#endif /* RollbarLoggerProtocol_h */
