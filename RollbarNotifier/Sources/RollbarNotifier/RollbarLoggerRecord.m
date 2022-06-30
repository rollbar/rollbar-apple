//
//  RollbarLoggerRecord.m
//  
//
//  Created by Andrey Kornich on 2022-06-28.
//

#import "RollbarLoggerRecord.h"
#import "RollbarLogger.h"
#import "RollbarLogger+Extension.h"

@implementation RollbarLoggerRecord

- (instancetype)initWithConfig:(nonnull RollbarConfig *)config
             andRegistryRecord:(nonnull RollbarLoggerRegistryRecord *)registryRecord {
    
    if (self = [super init]) {
        
        self->_logger = [[RollbarLogger alloc] initWithConfiguration:config andLoggerRecord:self];
        self->_registryRecord = registryRecord;
    }
    
    return self;
}

@end
