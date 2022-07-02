//
//  RollbarLoggerRegistry.m
//  
//
//  Created by Andrey Kornich on 2022-06-28.
//

#import "RollbarLoggerRegistry.h"
#import "RollbarLoggerRegistryRecord.h"
#import "RollbarLoggerRecord.h"

#import "RollbarLogger.h"
#import "RollbarLogger+Extension.h"

#import "RollbarConfig.h"
#import "RollbarDestination.h"

const NSUInteger DEFAULT_RegistryCapacity = 10;

@implementation RollbarLoggerRegistry {
    @private
    NSMutableDictionary<NSString *, RollbarLoggerRegistryRecord *> *_registryRecords;
}

- (instancetype)init {
    
    if (self = [super init]) {
        self->_registryRecords = [NSMutableDictionary dictionaryWithCapacity:DEFAULT_RegistryCapacity];
    }
    return self;
}

- (nonnull RollbarLogger *)loggerWithConfiguration:(nonnull RollbarConfig *)config {

    NSAssert(config, @"Config must not be null!");

    NSString *destinationID = [RollbarLoggerRegistry destinationID:config.destination];
    
    RollbarLoggerRegistryRecord *registryRecord = self->_registryRecords[destinationID];
    if (!registryRecord) {
        registryRecord = [[RollbarLoggerRegistryRecord alloc] initWithDestinationID:destinationID
                                                                        andRegistry:self
        ];
        self->_registryRecords[destinationID] = registryRecord;
    }
    
    RollbarLogger *logger = [registryRecord addLoggerWithConfig:config];
    return logger;
}

- (void)unregisterLogger:(nonnull RollbarLogger *)logger {
    [logger.loggerRecord.registryRecord removeLoggerRecord:logger.loggerRecord];
}

- (NSUInteger)totalDestinationRecords {
    return self->_registryRecords.count;
}

- (NSUInteger)totalLoggerRecords {
    NSUInteger total = 0;
    for (RollbarLoggerRegistryRecord *destinationRecord in self->_registryRecords.allValues) {
        total += destinationRecord.totalLoggerRecords;
    }
    return total;
}

- (nonnull NSString *)description {
    NSString *description = [NSString stringWithFormat:@"%@ - totalDestinationRecords: %lu, record keys: %@",
                             super.description,
                             (unsigned long)[self totalDestinationRecords],
                             self->_registryRecords.allKeys.description
    ];
    return description;
}

+ (nonnull NSString *)destinationID:(nonnull RollbarDestination *)destination {
    
    NSString *destinationID = [NSString stringWithFormat:@"%@|%@",
                               destination.endpoint,
                               destination.accessToken];
    return destinationID;
}

@end
