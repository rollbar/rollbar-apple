@import RollbarCommon;

NS_ASSUME_NONNULL_BEGIN

@interface RollbarMessage : RollbarDTO

// Required: body
// The primary message text, as a string
@property (nonatomic, copy, nonnull) NSString *body;

// NOTE:
// =====
// Can also contain any arbitrary keys of metadata. Their values can be any valid JSON.
// For example:
// "route": "home#index",
// "time_elapsed": 15.23

#pragma mark - Initializers

-(instancetype)initWithBody:(nonnull NSString *)messageBody;
-(instancetype)initWithNSError:(nonnull NSError *)error;

@end

NS_ASSUME_NONNULL_END
