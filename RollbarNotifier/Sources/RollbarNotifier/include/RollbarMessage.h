@import RollbarCommon;

NS_ASSUME_NONNULL_BEGIN

/// Message element of a payload
/// @note:
/// Can also contain any arbitrary keys of metadata. Their values can be any valid JSON.
/// For example:
/// "route": "home#index",
/// "time_elapsed": 15.23
@interface RollbarMessage : RollbarDTO

/// Required: body
/// The primary message text, as a string
@property (nonatomic, copy, nonnull) NSString *body;


#pragma mark - Initializers

/// Initializer
/// @param messageBody message content
-(instancetype)initWithBody:(nonnull NSString *)messageBody;

/// Initializer
/// @param error an error to use as the message content
-(instancetype)initWithNSError:(nonnull NSError *)error;

@end

NS_ASSUME_NONNULL_END
