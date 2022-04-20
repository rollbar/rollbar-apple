#ifndef RollbarServerConfig_h
#define RollbarServerConfig_h

@import RollbarCommon;

NS_ASSUME_NONNULL_BEGIN

/// Server config setting of a configuration
@interface RollbarServerConfig : RollbarDTO

#pragma mark - properties

/// Servef host
@property (nonatomic, copy, nullable) NSString *host;

/// Server code root
@property (nonatomic, copy, nullable) NSString *root;

/// Server code branch
@property (nonatomic, copy, nullable) NSString *branch;

/// Server code version
@property (nonatomic, copy, nullable) NSString *codeVersion;

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

@end

NS_ASSUME_NONNULL_END

#endif //RollbarServerConfig_h
