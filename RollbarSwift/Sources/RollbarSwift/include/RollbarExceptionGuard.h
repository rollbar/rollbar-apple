//
//  RollbarExceptionGuard.h
//  
//
//  Created by Andrey Kornich on 2021-03-04.
//

#import <Foundation/Foundation.h>

@import RollbarNotifier;

@class RollbarLogger;

NS_ASSUME_NONNULL_BEGIN

@interface RollbarExceptionGuard : NSObject

-(BOOL)execute:(nonnull void(NS_NOESCAPE^)(void))block;

-(BOOL)tryExecute:(nonnull void(NS_NOESCAPE^)(void))block
            error:(__autoreleasing NSError * _Nullable * _Nullable)error;

-(instancetype)initWithLogger:(nonnull RollbarLogger *)logger
NS_DESIGNATED_INITIALIZER;

-(instancetype)init
NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
