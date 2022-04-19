@import RollbarCommon;

NS_ASSUME_NONNULL_BEGIN

/// Exception specifc data element of a payload
@interface RollbarException : RollbarDTO

#pragma mark - Properties

/// Required: class
/// The exception class name.
@property (nonatomic, copy, nonnull) NSString *exceptionClass;

/// Optional: message
/// The exception message, as a string
@property (nonatomic, copy, nullable) NSString *exceptionMessage;

/// Optional: description
/// An alternate human-readable string describing the exception
/// Usually the original exception message will have been machine-generated;
/// you can use this to send something custom
@property (nonatomic, copy, nullable) NSString *exceptionDescription;

#pragma mark - Initializers

/// Initializer
/// @param exceptionClass exception class
/// @param exceptionMessage exception message
/// @param exceptionDescription exception description
- (instancetype)initWithExceptionClass:(nonnull NSString *)exceptionClass
                      exceptionMessage:(nullable NSString *)exceptionMessage
                  exceptionDescription:(nullable NSString *)exceptionDescription;

@end

NS_ASSUME_NONNULL_END
