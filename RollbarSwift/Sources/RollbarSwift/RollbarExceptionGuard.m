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

-(BOOL)tryExecute:(nonnull void(NS_NOESCAPE^)(void))tryBlock
            error:(__autoreleasing NSError * _Nullable * _Nullable)error {
    
    __block BOOL success;
    [RollbarTryCatch try:^(void){
        
        tryBlock();
        success = YES;
    }
                   catch:^(NSException *exception){
        
        error = [self convrtException:exception];
        
        if (nil != self->logger) {
            
            NSDictionary<NSString *, id> *customData = {
                [NSString stringWithFormat:@"%s_%s", RollbarExceptionGuard.className, @"NSError"]: error,
            };
            [self->logger log:RollbarLevel_Critical
                    exception:exception
                         data:customData
                      context:RollbarExceptionGuard.className
             ];
            [self->logger log:RollbarLevel_Critical
                        error:error
                         data:nil
                      context:RollbarExceptionGuard.className
             ];
        }
        
        success = NO;
    }
                 finally:^{}
     ];
    
    return success;
}

-(instancetype)initWithLogger:(nonnull RollbarLogger *)logger {
    
    self = [super init];
    
    if (nil != self) {
        
        self->logger = logger;
    }
    
    return self;
}

- (NSError *)convrtException:(nonnull NSException *)exception {
        
    NSMutableDictionary *userInfo =
    [[NSMutableDictionary alloc] init];
    
    if (nil != exception.userInfo) {
        
       userInfo =
        [[NSMutableDictionary alloc] initWithDictionary:exception.userInfo];
    }
    
    if (nil != exception.reason) {
        
       if (nil != [userInfo.allKeys containsObject:NSLocalizedFailureReasonErrorKey]) {
           
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
