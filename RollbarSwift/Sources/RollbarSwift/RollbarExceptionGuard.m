//
//  RollbarExceptionGuard.m
//  
//
//  Created by Andrey Kornich on 2021-03-04.
//

#import "RollbarExceptionGuard.h"
#import "RollbarTryCatch.h"

@implementation RollbarExceptionGuard {
@private
    RollbarLogger *logger;
}

-(BOOL)tryExecute:(nonnull void(NS_NOESCAPE^)(void))block {
    NSError *error = nil;
    return [self execute:block error:&error];
}

-(BOOL)execute:(nonnull void(NS_NOESCAPE^)(void))tryBlock
            error:(__autoreleasing NSError * _Nullable * _Nullable)error {
    
    __block BOOL success = NO;
    __block NSError* exceptionError = nil;
    
    [RollbarTryCatch try:^(void) {
            
            tryBlock();
            success = YES;
        }
                       catch:^(NSException *exception) {
            
            exceptionError = [self convertException:exception];
            
            if (nil != self->logger) {
                
                [self->logger log:RollbarLevel_Critical
                        exception:exception
                             data:nil
                          context:RollbarExceptionGuard.className
                 ];
                
                [self->logger log:RollbarLevel_Critical
                            error:exceptionError
                             data:nil
                          context:RollbarExceptionGuard.className
                 ];
            }
            
            success = NO;
        }
                     finally:^{
            
        }
     ];
    
    *error = exceptionError;
    
    return success;
}

-(instancetype)initWithLogger:(nonnull RollbarLogger *)logger {
    
    self = [super init];
    
    if (nil != self) {
        
        self->logger = logger;
    }
    
    return self;
}

- (NSError *)convertException:(nonnull NSException *)exception {
        
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    
    if ((nil != exception.userInfo) && (0 < exception.userInfo.count)) {
        
       userInfo =
        [[NSMutableDictionary alloc] initWithDictionary:exception.userInfo];
    }
    
    if (nil != exception.reason) {
        
       if (YES == [userInfo.allKeys containsObject:NSLocalizedFailureReasonErrorKey]) {
           
          [userInfo setObject:exception.reason
                       forKey:NSLocalizedFailureReasonErrorKey];
       }
    }
    
    NSError *error = [[NSError alloc] initWithDomain:exception.name
                                                code:0
                                            userInfo:userInfo];
    
    return error;
}

@end
