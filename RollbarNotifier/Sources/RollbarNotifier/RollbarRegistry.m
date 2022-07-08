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

- (nonnull RollbarDestinationRecord *)getRecordForDestination:(nonnull RollbarDestination *)destination {
    
    NSAssert(destination, @"Destination must not be null!");
    
    NSString *destinationID = [RollbarRegistry destinationID:destination];
    RollbarDestinationRecord *destinationRecord = self->_destinationRecords[destinationID];
    if (!destinationRecord) {
        destinationRecord = [[RollbarDestinationRecord alloc] initWithDestinationID:destinationID
                                                                        andRegistry:self
        ];
        self->_destinationRecords[destinationID] = destinationRecord;
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
