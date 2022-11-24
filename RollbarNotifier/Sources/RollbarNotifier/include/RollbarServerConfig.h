#ifndef RollbarServerConfig_h
#define RollbarServerConfig_h

@import RollbarCommon;

NS_ASSUME_NONNULL_BEGIN

/// Server config setting of a configuration
@interface RollbarServerConfig : RollbarDTO

#pragma mark - initializers

/// Initializer
/// @param host server host
/// @param root server code root
/// @param branch code branch
/// @param codeVersion code version
- (instancetype)initWithHost:(nullable NSString *)host
                        root:(nullable NSString *)root
                      branch:(nullable NSString *)branch
                 codeVersion:(nullable NSString *)codeVersion;

#pragma mark - properties

/// Servef host
@property (nonatomic, copy, nullable, readonly) NSString *host;

/// Server code root
@property (nonatomic, copy, nullable, readonly) NSString *root;

/// Server code branch, readonly
@property (nonatomic, copy, nullable, readonly) NSString *branch;

/// Server code version, readonly
@property (nonatomic, copy, nullable, readonly) NSString *codeVersion;

@end


/// Mutable Server config setting of a configuration
@interface RollbarMutableServerConfig : RollbarServerConfig

#pragma mark - properties

/// Servef host
@property (nonatomic, copy, nullable, readwrite) NSString *host;

/// Server code root
@property (nonatomic, copy, nullable, readwrite) NSString *root;

/// Server code branch
@property (nonatomic, copy, nullable, readwrite) NSString *branch;

/// Server code version
@property (nonatomic, copy, nullable, readwrite) NSString *codeVersion;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarServerConfig_h
