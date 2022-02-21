@import RollbarCommon;

NS_ASSUME_NONNULL_BEGIN

/// Module element of a payload
@interface RollbarModule : RollbarDTO

#pragma mark - properties

/// Optional: name
/// Name of the library
@property (nonatomic, copy, nullable) NSString *name;

/// Optional: version
/// Library version string
@property (nonatomic, copy, nullable) NSString *version;

#pragma mark - initializers

/// Initializer
/// @param name module name
/// @param version module version
- (instancetype)initWithName:(nullable NSString *)name
                     version:(nullable NSString *)version;

/// Initializer
/// @param name module name
- (instancetype)initWithName:(nullable NSString *)name;

@end

NS_ASSUME_NONNULL_END
