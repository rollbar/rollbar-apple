#import "RollbarDestinationRecord.h"
#import "RollbarLoggerRecord.h"
#import "RollbarLogger.h"
#import "RollbarConfig.h"
#import "RollbarDestination.h"

const NSUInteger DEFAULT_DestinationRecordCapacity = 10;

@implementation RollbarDestinationRecord {
    @private
    NSMutableSet<RollbarLoggerRecord *> *_loggerRecords;
}

#pragma mark - property accessors

- (NSSet<RollbarLoggerRecord *> *)loggerRecords {
    
    return [_loggerRecords copy];
}

#pragma mark - initializers

- (instancetype)initWithDestinationID:(nonnull NSString *)destinationID
                          andRegistry:(RollbarLoggerRegistry *)registry {
    
    if (self = [super init]) {
        
        self->_registry = registry;
        self->_destinationID = destinationID;
        self->_loggerRecords = [NSMutableSet setWithCapacity:DEFAULT_DestinationRecordCapacity];
    }
    return self;
}

#pragma mark - overrides

- (nonnull NSString *)description {
    NSString *description = [NSString stringWithFormat:@"%@ - totalLoggerRecords: %lu",
                             super.description,
                             (unsigned long)[self totalLoggerRecords]
    ];
    return description;
}

#pragma mark - de/registration of loggers

- (nonnull RollbarLogger *)addLoggerWithConfig:(nonnull RollbarConfig *)loggerConfig {
    
    RollbarLoggerRecord *loggerRecord = [[RollbarLoggerRecord alloc] initWithConfig:loggerConfig
                                                               andDestinationRecord:self];
    [self->_loggerRecords addObject:loggerRecord];
    return loggerRecord.logger;
}

//- (void)removeLogger:(nonnull RollbarLogger *)logger {
//    
//    RollbarLoggerRecord *loggerRecord = nil;
//    for (RollbarLoggerRecord *record in self->_loggerRecords) {
//        if (logger == record.logger) {
//            loggerRecord = record;
//            break;
//        }
//    }
//    
//    if (loggerRecord) {
//        [self removeLoggerRecord:loggerRecord];
//    }
//    else {
//        NSAssert(NO, @"Something wrong removing logger record from the registry!");
//    }
//}

- (void)removeLoggerRecord:(nonnull RollbarLoggerRecord *)loggerRecord {
 
    [self->_loggerRecords removeObject:loggerRecord];
}

- (NSUInteger)totalLoggerRecords {

    return self->_loggerRecords.count;
}

- (NSString *)debugDescription {
    NSString *description = [NSString stringWithFormat:@"totalLoggerRecords: %lu",
                             (unsigned long)[self totalLoggerRecords]
    ];
    return description;
}

@end
