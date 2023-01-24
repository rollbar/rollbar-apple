#ifndef RollbarBody_h
#define RollbarBody_h

@import RollbarCommon;

@class RollbarTelemetry;
@class RollbarTrace;
@class RollbarMessage;
@class RollbarCrashReport;
@class RollbarTelemetryEvent;

NS_ASSUME_NONNULL_BEGIN

/// RollbarBody payload element
///
/// @note:
/// Required: "trace", "trace_chain", "message", or "crash_report" (exactly one)
/// If this payload is a single exception, use "trace"
/// If a chain of exceptions (for languages that support inner exceptions), use "trace_chain"
/// If a message with no stack trace, use "message"
/// If an application crash report, use "crash_report"
@interface RollbarBody : RollbarDTO

/// Initializer
/// @param message a message
-(instancetype)initWithMessage:(nonnull NSString *)message;

/// Initializer
/// @param message a message
/// @param extra Optional parameter for backwards compatibility for customers
///              that still rely on an undocumented feature.
- (instancetype)initWithMessage:(nonnull NSString *)string
                          extra:(nullable NSDictionary *)extra;

/// Initializer
/// @param exception an exception
-(instancetype)initWithException:(nonnull NSException *)exception;

/// Initializer
/// @param error an error
-(instancetype)initWithError:(nonnull NSError *)error;

/// Initializer
/// @param crashReport a crash report
-(instancetype)initWithCrashReport:(nonnull NSString *)crashReport;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarBody_h
