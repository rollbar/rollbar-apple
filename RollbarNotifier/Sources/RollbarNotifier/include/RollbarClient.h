@import RollbarCommon;

@class RollbarJavascript;

NS_ASSUME_NONNULL_BEGIN

/// RollbarClient payload element
///
/// @note:
/// Can contain any arbitrary keys. Rollbar understands the following:
@interface RollbarClient : RollbarDTO

#pragma mark - Properties

/// Optional: cpu
/// A string up to 255 characters
@property (nonatomic, copy, nullable) NSString *cpu;

/// javaScript
@property (nonatomic, strong, nullable) RollbarJavascript *javaScript;

#pragma mark - Initializers

/// Initializer
/// @param cpu CPU
/// @param javaScript javaScript
-(instancetype)initWithCpu:(nullable NSString *)cpu
                javaScript:(nullable RollbarJavascript *)javaScript;

@end

NS_ASSUME_NONNULL_END
