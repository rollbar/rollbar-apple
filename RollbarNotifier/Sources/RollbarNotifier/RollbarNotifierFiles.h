//
//  RollbarNotifierFiles.h
//  
//
//  Created by Andrey Kornich on 2022-06-06.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RollbarNotifierFiles : NSObject

#pragma mark - notifier files

+ (nonnull NSString * const)itemsQueue;
+ (nonnull NSString * const)itemsQueueState;

+ (nonnull NSString * const)telemetryQueue;

+ (nonnull NSString * const)runtimeSession;

+ (nonnull NSString * const)appQuit;

+ (nonnull NSString * const)payoadsLog;

+ (nonnull NSString * const)config;

#pragma mark - static utility nature

+ (instancetype)new NS_UNAVAILABLE;
+ (instancetype)allocWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;
+ (instancetype)alloc NS_UNAVAILABLE;
+ (id)copyWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;
+ (id)mutableCopyWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
