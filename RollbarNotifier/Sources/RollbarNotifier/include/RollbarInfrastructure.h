//
//  RollbarInfrastructure.h
//  
//
//  Created by Andrey Kornich on 2022-06-09.
//

#ifndef RollbarInfrastructure_h
#define RollbarInfrastructure_h

#import <Foundation/Foundation.h>

#import "RollbarLoggerProtocol.h"
#import "RollbarConfig.h"
#import "RollbarCrashCollectorProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface RollbarInfrastructure : NSObject

#pragma mark - propeties

@property(readonly, nonnull) RollbarConfig *configuration;
@property(readonly, nonnull) id<RollbarLogger> logger;

#pragma mark - instance methods

- (nonnull instancetype)configureWith:(nonnull RollbarConfig *)config;
- (nonnull instancetype)configureWith:(nonnull RollbarConfig *)config
                    andCrashCollector:(nullable id<RollbarCrashCollector>)crashCollector;
- (nonnull id<RollbarLogger>)createLogger;
- (nonnull id<RollbarLogger>)createLoggerWithConfig:(nonnull RollbarConfig *)config;
- (nonnull id<RollbarLogger>)createLoggerWithAccessToken:(nonnull NSString *)token
                                          andEnvironment:(nonnull NSString *)env;
- (nonnull id<RollbarLogger>)createLoggerWithAccessToken:(nonnull NSString *)token;

#pragma mark - class methods

//+ (nonnull id<RollbarLogger>)sharedLogger;
//+ (nonnull id<RollbarLogger>)newLogger;
//+ (nonnull id<RollbarLogger>)newLoggerWithConfig:(nonnull RollbarConfig *)config;
//+ (nonnull id<RollbarLogger>)newLoggerWithAccessToken:(nonnull NSString *)token
//                                       andEnvironment:(nonnull NSString *)env;
//+ (nonnull id<RollbarLogger>)newLoggerWithAccessToken:(nonnull NSString *)token;

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
