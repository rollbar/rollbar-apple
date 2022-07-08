#import "RollbarDestinationRecord.h"

@implementation RollbarDestinationRecord {
    @private
}

#pragma mark - property accessors

#pragma mark - initializers

- (instancetype)initWithDestinationID:(nonnull NSString *)destinationID
                          andRegistry:(nonnull RollbarRegistry *)registry {
    
    if (self = [super init]) {
        
        self->_registry = registry;
        self->_destinationID = destinationID;
    }
    return self;
}

#pragma mark - overrides

- (nonnull NSString *)description {
    NSString *description = [NSString stringWithFormat:@"%@",
                             super.description
    ];
    return description;
}

//- (NSString *)debugDescription {
//    NSString *description = [NSString stringWithFormat:@"totalLoggerRecords: %lu",
//                             (unsigned long)[self totalLoggerRecords]
//    ];
//    return description;
//}

@end
