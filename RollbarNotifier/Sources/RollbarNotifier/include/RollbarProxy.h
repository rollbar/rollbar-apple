@import RollbarCommon;

NS_ASSUME_NONNULL_BEGIN

@interface RollbarProxy : RollbarDTO

#pragma mark - properties
@property (nonatomic) BOOL enabled;
@property (nonatomic, copy) NSString *proxyUrl;
@property (nonatomic) NSUInteger proxyPort;

#pragma mark - initializers

- (instancetype)initWithEnabled:(BOOL)enabled
                       proxyUrl:(NSString *)proxyUrl
                      proxyPort:(NSUInteger)proxyPort;

@end

NS_ASSUME_NONNULL_END
