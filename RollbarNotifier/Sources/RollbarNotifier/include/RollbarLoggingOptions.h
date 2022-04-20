#ifndef RollbarLoggingOptions_h
#define RollbarLoggingOptions_h

#import "RollbarLevel.h"
#import "RollbarCaptureIpType.h"
@import RollbarCommon;

NS_ASSUME_NONNULL_BEGIN

/// Models logging settings of a configuration
@interface RollbarLoggingOptions : RollbarDTO

#pragma mark - Properties

/// A minimum threshold level to log from
@property (nonatomic) RollbarLevel logLevel;

/// A log level to use for crsh reports
@property (nonatomic) RollbarLevel crashLevel;

/// Reporting rate limit
@property (nonatomic) NSUInteger maximumReportsPerMinute;

/// A way of capturing IP addresses
@property (nonatomic) RollbarCaptureIpType captureIp;

/// A code version to mark payloads with
@property (nonatomic, copy, nullable) NSString *codeVersion;

/// A framework tag to mark payloads with
@property (nonatomic, copy, nullable) NSString *framework;

/// A request ID to mark payloads with
@property (nonatomic, copy, nullable) NSString *requestId;

#pragma mark - Initializers

/// Initializer
/// @param logLevel minimum log level to start logging from
/// @param crashLevel log level to mark crash reports with
/// @param maximumReportsPerMinute Reporting rate limit
/// @param captureIp a way of capturing IP addresses
/// @param codeVersion a code version to mark payloads with
/// @param framework A framework tag to mark payloads with
/// @param requestId A request ID to mark payloads with
- (instancetype)initWithLogLevel:(RollbarLevel)logLevel
                      crashLevel:(RollbarLevel)crashLevel
         maximumReportsPerMinute:(NSUInteger)maximumReportsPerMinute
                       captureIp:(RollbarCaptureIpType)captureIp
                     codeVersion:(nullable NSString *)codeVersion
                       framework:(nullable NSString *)framework
                       requestId:(nullable NSString *)requestId;

/// Initializer
/// @param logLevel minimum log level to start logging from
/// @param crashLevel log level to mark crash reports with
/// @param maximumReportsPerMinute Reporting rate limit
/// @param codeVersion a code version to mark payloads with
/// @param framework A framework tag to mark payloads with
/// @param requestId A request ID to mark payloads with
- (instancetype)initWithLogLevel:(RollbarLevel)logLevel
                      crashLevel:(RollbarLevel)crashLevel
         maximumReportsPerMinute:(NSUInteger)maximumReportsPerMinute
                     codeVersion:(nullable NSString *)codeVersion
                       framework:(nullable NSString *)framework
                       requestId:(nullable NSString *)requestId;

/// Initializer
/// @param logLevel minimum log level to start logging from
/// @param crashLevel log level to mark crash reports with
/// @param captureIp a way of capturing IP addresses
/// @param codeVersion a code version to mark payloads with
/// @param framework A framework tag to mark payloads with
/// @param requestId A request ID to mark payloads with
- (instancetype)initWithLogLevel:(RollbarLevel)logLevel
                      crashLevel:(RollbarLevel)crashLevel
                       captureIp:(RollbarCaptureIpType)captureIp
                     codeVersion:(nullable NSString *)codeVersion
                       framework:(nullable NSString *)framework
                       requestId:(nullable NSString *)requestId;

/// Initializer
/// @param logLevel minimum log level to start logging from
/// @param crashLevel log level to mark crash reports with
/// @param codeVersion a code version to mark payloads with
/// @param framework A framework tag to mark payloads with
/// @param requestId A request ID to mark payloads with
- (instancetype)initWithLogLevel:(RollbarLevel)logLevel
                      crashLevel:(RollbarLevel)crashLevel
                     codeVersion:(nullable NSString *)codeVersion
                       framework:(nullable NSString *)framework
                       requestId:(nullable NSString *)requestId;

/// Initializer
/// @param logLevel minimum log level to start logging from
/// @param crashLevel log level to mark crash reports with
/// @param maximumReportsPerMinute Reporting rate limit
- (instancetype)initWithLogLevel:(RollbarLevel)logLevel
                      crashLevel:(RollbarLevel)crashLevel
         maximumReportsPerMinute:(NSUInteger)maximumReportsPerMinute;

/// Initializer
/// @param logLevel minimum log level to start logging from
/// @param crashLevel log level to mark crash reports with
- (instancetype)initWithLogLevel:(RollbarLevel)logLevel
                      crashLevel:(RollbarLevel)crashLevel;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarLoggingOptions_h
