@import RollbarCommon;

@class RollbarCallStackFrame;
@class RollbarException;

NS_ASSUME_NONNULL_BEGIN

/// Trace data element of a payload
@interface RollbarTrace : RollbarDTO

#pragma mark - Properties

/// Required: frames
/// A list of stack frames, ordered such that the most recent call is last in the list.
@property (nonatomic, nonnull) NSArray<RollbarCallStackFrame *> *frames;

/// Required: exception
/// An object describing the exception instance.
@property (nonatomic, nonnull) RollbarException *exception;

#pragma mark - Initializers

/// Initializer
/// @param exception exception
/// @param frames exception call stack frames
-(instancetype)initWithRollbarException:(nonnull RollbarException *)exception
                 rollbarCallStackFrames:(nonnull NSArray<RollbarCallStackFrame *> *)frames;

/// Initializer
/// @param exception exception
-(instancetype)initWithException:(nonnull NSException *)exception;

/// Initializer
/// @param crashReport crash report content
-(instancetype)initWithCrashReport:(nonnull NSString *)crashReport;

@end

NS_ASSUME_NONNULL_END
