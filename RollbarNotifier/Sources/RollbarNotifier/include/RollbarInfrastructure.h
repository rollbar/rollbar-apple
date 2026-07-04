#ifndef RollbarInfrastructure_h
#define RollbarInfrastructure_h

#import <Foundation/Foundation.h>
#import "RollbarLoggerProtocol.h"
#import "RollbarConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface RollbarInfrastructure : NSObject

@property (readonly, strong) RollbarConfig *configuration;
@property (readonly, strong) id<RollbarLogger> logger;

- (instancetype)configureWith:(RollbarConfig *)config;

#pragma mark - Sigleton pattern

+ (instancetype)sharedInstance;

+ (instancetype)new NS_UNAVAILABLE;
+ (instancetype)allocWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;
+ (instancetype)alloc NS_UNAVAILABLE;
+ (id)copyWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;
+ (id)mutableCopyWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;
- (void)dealloc NS_UNAVAILABLE;
- (id)copy NS_UNAVAILABLE;
- (id)mutableCopy NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarInfrastructure_h
