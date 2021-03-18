//
//  RollbarExceptionGuard.h
//  
//
//  Created by Andrey Kornich on 2021-03-04.
//

@import Foundation;

@class RollbarLogger;

NS_ASSUME_NONNULL_BEGIN

///  Aids Swift code in handling NSExceptions thrown from within Objective-C calls
@interface RollbarExceptionGuard : NSObject

/// Allows to safely execute code that could potentially throw NSExceptions.
/// @param block guarded code block
-(BOOL)tryExecute:(nonnull void(NS_NOESCAPE^)(void))block;

/// Allows to safely execute code that could potentially throw NSExceptions.
/// @param block guarded code block
/// @param error NSError instance modeling corresponding NSException (if any thown from the guarded code block)
-(BOOL)execute:(nonnull void(NS_NOESCAPE^)(void))block
            error:(__autoreleasing NSError * _Nullable * _Nullable)error;

/// Designated initializer
/// @param logger RollbarLogger instance to use when reporting intercepted NSExceptions captured by this guard instance
-(instancetype)initWithLogger:(nonnull RollbarLogger *)logger
NS_DESIGNATED_INITIALIZER;

/// Unavailable initializer
-(instancetype)init
NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
