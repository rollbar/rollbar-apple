#import "RollbarRegistry.h"
#import "RollbarDestinationRecord.h"

const NSUInteger DEFAULT_RegistryCapacity = 10;

@implementation RollbarRegistry {
    @private
    NSMutableDictionary<NSString *, RollbarDestinationRecord *> *_destinationRecords;
}

- (instancetype)init {
    
    if (self = [super init]) {
        self->_destinationRecords = [NSMutableDictionary dictionaryWithCapacity:DEFAULT_RegistryCapacity];
    }
    return self;
}

- (nonnull RollbarDestinationRecord *)getRecordForConfig:(nonnull RollbarConfig *)config {
    
    NSAssert(config, @"Config must not be null!");
    NSAssert(config.destination, @"Destination must not be null!");
    
    NSString *destinationID = [RollbarRegistry destinationID:config.destination];
    RollbarDestinationRecord *destinationRecord = self->_destinationRecords[destinationID];
    if (!destinationRecord) {
        destinationRecord = [[RollbarDestinationRecord alloc] initWithDestinationID:destinationID
                                                                        andRegistry:self
        ];
        self->_destinationRecords[destinationID] = destinationRecord;
    }

    if (destinationRecord.localWindowLimit < config.loggingOptions.maximumReportsPerMinute) {
        
        // we use lagest configured limit per destination:
        destinationRecord.localWindowLimit = config.loggingOptions.maximumReportsPerMinute;
    }
    
    return destinationRecord;
}

- (NSUInteger)totalDestinationRecords {
    return self->_destinationRecords.count;
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
