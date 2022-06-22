//
//  RollbarInfrastructure.h
//  
//
//  Created by Andrey Kornich on 2022-06-09.
//

#ifndef RollbarInfrastructure_h
#define RollbarInfrastructure_h

#import <Foundation/Foundation.h>

@class RollbarConfig;
@class RollbarLogger;

NS_ASSUME_NONNULL_BEGIN

@interface RollbarInfrastructure : NSObject

- (nonnull instancetype)configureWith:(nonnull RollbarConfig *)rollbarConfig;

@property(readonly, nonnull) RollbarConfig *configuration;
@property(readonly, nonnull) RollbarLogger *logger;

#pragma mark - Sigleton pattern

+ (nonnull instancetype)sharedInstance;

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
