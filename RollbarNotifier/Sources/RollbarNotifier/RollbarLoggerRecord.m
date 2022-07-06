#import "RollbarLoggerRecord.h"
#import "RollbarLogger.h"
#import "RollbarLogger+Extension.h"
#import "RollbarInfrastructure.h"

@implementation RollbarLoggerRecord {
    @private
    BOOL _isInScope;
}

//- (BOOL)isInScope {
//
//    if (self->_logger == [RollbarInfrastructure sharedInstance].logger) {
//        return NO;
//    }
//    else {
//        return self->_isInScope;
//    }
//}

- (void)markAsOutOfScope {
    
    self->_isInScope = NO;
}

- (instancetype)initWithConfig:(nonnull RollbarConfig *)config
             andDestinationRecord:(nonnull RollbarDestinationRecord *)destinationRecord {
    
    if (self = [super init]) {
        
        self->_isInScope = YES;
        
        self->_logger = [[RollbarLogger alloc] initWithConfiguration:config
                                                     andLoggerRecord:self];
        self->_destinationRecord = destinationRecord;
    }
    
    return self;
}

@end
