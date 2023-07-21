#ifndef RollbarBody_h
#define RollbarBody_h

@import RollbarCommon;

@class RollbarTelemetry;
@class RollbarTrace;
@class RollbarMessage;
@class RollbarRawCrashReport;
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

#pragma mark - Required but mutually exclusive properties

/// Payload Option 1: "trace"
@property (nonatomic, strong, nullable) RollbarTrace *trace;

/// Payload Option 2: "trace_chain"
/// Used for exceptions with inner exceptions or causes
/// Each element in the list should be a "trace" object, as shown above.
/// Must contain at least one element.
@property (nonatomic,strong, nullable) NSArray<RollbarTrace *> *traceChain;

/// Payload Option 3: "message"
/// Only one of "trace", "trace_chain", "message", or "crash_report" should be present.
/// Presence of a "message" key means that this payload is a log message.
@property (nonatomic, strong, nullable) RollbarMessage *message;

// Payload Option 4: "crash_report"
// Only one of "trace", "trace_chain", "message", or "crash_report" should be present.
@property (nonatomic, strong, nullable) RollbarRawCrashReport *crashReport;

#pragma mark - Optional properties

/// Optional: "telemetry".
/// Only applicable if you are sending telemetry data.
@property (readonly, nonatomic, strong, nullable) NSArray<RollbarTelemetryEvent *> *telemetry;

#pragma mark - Initializers

/// Initializer
/// @param message a message
-(instancetype)initWithMessage:(nonnull NSString *)message;

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
