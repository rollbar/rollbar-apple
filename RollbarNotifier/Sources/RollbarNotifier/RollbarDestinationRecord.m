#import "RollbarDestinationRecord.h"
#import "RollbarRegistry.h"

@implementation RollbarDestinationRecord {
    @private
}

#pragma mark - property accessors

#pragma mark - initializers

- (instancetype)initWithConfig:(nonnull RollbarConfig *)config
                   andRegistry:(nonnull RollbarRegistry *)registry {
    
    NSAssert(config, @"Config can not be nil!");
    NSAssert(config.destination, @"Config destination can not be nil!");
    NSAssert(registry, @"Registry can not be nil!");
    
    if (self = [super init]) {
        
        self->_registry = registry;
        self->_destinationID = [RollbarRegistry destinationID:config.destination];
        self->_localWindowLimit = config.loggingOptions.maximumReportsPerMinute;
        self->_localWindowCount = 0;
        self->_serverWindowCount =0;
        self->_nextLocalWindowStart = nil;
        self->_nextServerWindowStart = nil;
    }
}

- (instancetype)initWithDestinationID:(nonnull NSString *)destinationID
                          andRegistry:(nonnull RollbarRegistry *)registry {
    
    if (self = [super init]) {
        
        self->_registry = registry;
        self->_destinationID = destinationID;
        self->_localWindowLimit = 0;
        self->_localWindowCount = 0;
        self->_serverWindowCount =0;
        self->_nextLocalWindowStart = nil;
        self->_nextServerWindowStart = nil;
    }
    return self;
}

#pragma mark - methods

- (BOOL)canPost {
 
    //TODO: implement...
    return YES;
}

- (void)recordPostReply:(nullable RollbarPayloadPostReply *)reply {
    
    //TODO: implement...
    //      should be able to process nil as reply!
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
