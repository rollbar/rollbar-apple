#ifndef RollbarProxy_h
#define RollbarProxy_h

@import RollbarCommon;

NS_ASSUME_NONNULL_BEGIN

/// Proxy settings of a configuration
@interface RollbarProxy : RollbarDTO

#pragma mark - properties

/// Enables/disables usage of these proxy settings
@property (nonatomic, readonly) BOOL enabled;

/// Proxy URI to use
@property (nonatomic, readonly, copy) NSString *proxyUrl;

/// Proxy port to use
@property (nonatomic, readonly) NSUInteger proxyPort;

#pragma mark - initializers

/// Initializer
/// @param enabled rnables/disables usage of these proxy settings
/// @param proxyUrl proxy URI
/// @param proxyPort proxy port
- (instancetype)initWithEnabled:(BOOL)enabled
                       proxyUrl:(NSString *)proxyUrl
                      proxyPort:(NSUInteger)proxyPort;

@end

@interface RollbarMutableProxy : RollbarProxy

#pragma mark - properties

/// Enables/disables usage of these proxy settings
@property (nonatomic, readwrite) BOOL enabled;

/// Proxy URI to use
@property (nonatomic, readwrite, copy) NSString *proxyUrl;

/// Proxy port to use
@property (nonatomic, readwrite) NSUInteger proxyPort;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarProxy_h
