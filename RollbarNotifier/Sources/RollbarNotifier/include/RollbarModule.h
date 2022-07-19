#ifndef RollbarModule_h
#define RollbarModule_h

@import RollbarCommon;

NS_ASSUME_NONNULL_BEGIN

/// Module element of a payload
@interface RollbarModule : RollbarDTO

#pragma mark - initializers

/// Initializer
/// @param name module name
/// @param version module version
- (instancetype)initWithName:(nullable NSString *)name
                     version:(nullable NSString *)version;

/// Initializer
/// @param name module name
- (instancetype)initWithName:(nullable NSString *)name;

- (instancetype)init
NS_UNAVAILABLE;

- (instancetype)new
NS_UNAVAILABLE;

#pragma mark - properties

/// Optional: name
/// Name of the library
@property (nonatomic, copy, nullable, readonly) NSString *name;

/// Optional: version
/// Library version string
@property (nonatomic, copy, nullable, readonly) NSString *version;

@end


/// Mutable Module element of a payload
@interface RollbarMutableModule : RollbarModule

#pragma mark - initializers

- (instancetype)init;

#pragma mark - properties

/// Optional: name
/// Name of the library
@property (nonatomic, copy, nullable, readwrite) NSString *name;

/// Optional: version
/// Library version string
@property (nonatomic, copy, nullable, readwrite) NSString *version;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarModule_h
