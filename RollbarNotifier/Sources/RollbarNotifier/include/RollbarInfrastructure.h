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

NS_ASSUME_NONNULL_BEGIN

@interface RollbarInfrastructure : NSObject

/// Current config object.
@property(readonly) RollbarConfig *config;

- (nonnull instancetype)configureWith:(RollbarConfig *)rollbarConfig;

/// Hides the initializer.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark - Sigleton pattern

+ (nonnull instancetype)sharedInstance;

+ (instancetype)new NS_UNAVAILABLE;
+ (instancetype)allocWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;
+ (instancetype)alloc NS_UNAVAILABLE;
+ (id)copyWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;
+ (id)mutableCopyWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;

- (void)dealloc NS_UNAVAILABLE;
- (id)copy NS_UNAVAILABLE;
- (id)mutableCopy NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarInfrastructure_h
