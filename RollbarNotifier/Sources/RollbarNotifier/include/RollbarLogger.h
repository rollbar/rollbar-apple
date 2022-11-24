#ifndef RollbarLogger_h
#define RollbarLogger_h

#import "RollbarLoggerProtocol.h"
@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/// Models interface of a Rollbar logger
@interface RollbarLogger : NSObject<RollbarLogger>


#pragma mark - //TODO: to be removed

- (void)updateConfiguration:(nonnull RollbarConfig *)configuration;
//- (void)updateAccessToken:(nonnull NSString *)accessToken;
//- (void)updateReportingRate:(NSUInteger)maximumReportsPerMinute;

//- (BOOL)sendItem:(nonnull NSDictionary *)payload
//      nextOffset:(NSUInteger)nextOffset;
//- (BOOL)sendPayload:(nonnull NSData *)payload;



#pragma mark - factory methods

+ (instancetype)loggerWithAccessToken:(nonnull NSString *)accessToken;
+ (instancetype)loggerWithAccessToken:(nonnull NSString *)accessToken
                       andEnvironment:(nonnull NSString *)environment;
+ (instancetype)loggerWithConfiguration:(nonnull RollbarConfig *)configuration;

#pragma mark - initializers

- (instancetype)initWithAccessToken:(nonnull NSString *)accessToken;
- (instancetype)initWithAccessToken:(nonnull NSString *)accessToken
                     andEnvironment:(nonnull NSString *)environment;
- (instancetype)initWithConfiguration:(nonnull RollbarConfig *)configuration
NS_DESIGNATED_INITIALIZER;

/// Disallowed initializer
- (instancetype)init
NS_UNAVAILABLE;

//#pragma mark - properties
//
///// Notifier's config object
//@property (nullable, atomic, strong) RollbarConfig *configuration;
//
//#pragma mark - logging methods
//
///// Captures a crash report
///// @param crashReport the crash report
//- (void)logCrashReport:(nonnull NSString *)crashReport;
//
///// Captures a log entry
///// @param level Rollbar error/log level
///// @param message message
///// @param data extra data
///// @param context extra context
//- (void)log:(RollbarLevel)level
//    message:(nonnull NSString *)message
//       data:(nullable NSDictionary<NSString *, id> *)data
//    context:(nullable NSString *)context;
//
///// Captures a log entry
///// @param level Rollbar error/log level
///// @param exception exception
///// @param data extra data
///// @param context extra context
//- (void)log:(RollbarLevel)level
//  exception:(nonnull NSException *)exception
//       data:(nullable NSDictionary<NSString *, id> *)data
//    context:(nullable NSString *)context;
//
///// Capture a log entry based on an NSError
///// @param level Rollbar error/log level
///// @param error an NSError
///// @param data extra data
///// @param context extra context
//- (void)log:(RollbarLevel)level
//      error:(nonnull NSError *)error
//       data:(nullable NSDictionary<NSString *, id> *)data
//    context:(nullable NSString *)context;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarLogger_h
