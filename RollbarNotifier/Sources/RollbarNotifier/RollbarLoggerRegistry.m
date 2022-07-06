#import "RollbarLoggerRegistry.h"
#import "RollbarDestinationRecord.h"
#import "RollbarLoggerRecord.h"

#import "RollbarLogger.h"
#import "RollbarLogger+Extension.h"

#import "RollbarConfig.h"
#import "RollbarDestination.h"

const NSUInteger DEFAULT_RegistryCapacity = 10;

@implementation RollbarLoggerRegistry {
    @private
    NSMutableDictionary<NSString *, RollbarDestinationRecord *> *_destinationRecords;
}

- (instancetype)init {
    
    if (self = [super init]) {
        self->_destinationRecords = [NSMutableDictionary dictionaryWithCapacity:DEFAULT_RegistryCapacity];
    }
    return self;
}

- (nonnull RollbarLogger *)loggerWithConfiguration:(nonnull RollbarConfig *)config {

    NSAssert(config, @"Config must not be null!");

    NSString *destinationID = [RollbarLoggerRegistry destinationID:config.destination];
    
    RollbarDestinationRecord *destinationRecord = self->_destinationRecords[destinationID];
    if (!destinationRecord) {
        destinationRecord = [[RollbarDestinationRecord alloc] initWithDestinationID:destinationID
                                                                        andRegistry:self
        ];
        self->_destinationRecords[destinationID] = destinationRecord;
    }
    
    RollbarLogger *logger = [destinationRecord addLoggerWithConfig:config];
    return logger;
}

- (void)unregisterLogger:(nonnull RollbarLogger *)logger {
    [logger.loggerRecord.destinationRecord removeLoggerRecord:logger.loggerRecord];
}

- (NSUInteger)totalDestinationRecords {
    return self->_destinationRecords.count;
}

- (NSUInteger)totalLoggerRecords {
    NSUInteger total = 0;
    for (RollbarDestinationRecord *destinationRecord in self->_destinationRecords.allValues) {
        total += destinationRecord.totalLoggerRecords;
    }
    return total;
}

#pragma mark - overrides

- (nonnull NSString *)description {
    NSString *description = [NSString stringWithFormat:@"%@ - totalDestinationRecords: %lu, records: %@",
                             super.description,
                             (unsigned long)[self totalDestinationRecords],
                             self->_destinationRecords
    ];
    return description;
}

#pragma mark - class methods

+ (nonnull NSString *)destinationID:(nonnull RollbarDestination *)destination {
    
    NSString *destinationID = [NSString stringWithFormat:@"%@|%@",
                               destination.endpoint,
                               destination.accessToken];
    return destinationID;
}

@end
