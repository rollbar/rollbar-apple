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
}
- (nonnull RollbarLogger *)loggerWithConfiguration:(nonnull RollbarConfig *)config {

    NSAssert(config, @"Config must not be null!");

    NSString *destinationID = [RollbarLoggerRegistry destinationID:config.destination];
    
    RollbarLoggerRegistryRecord *registryRecord = self->_registryRecords[destinationID];
    if (!registryRecord) {
        registryRecord = [[RollbarLoggerRegistryRecord alloc] initWithDestinationID:destinationID
                                                                        andRegistry:self
        ];
    }
    
    RollbarLogger *logger = [registryRecord addLoggerWithConfig:config];
    return logger;
}

- (void)unregisterLogger:(nonnull RollbarLogger *)logger {
    [logger.loggerRecord.registryRecord removeLoggerRecord:logger.loggerRecord];
}

- (NSUInteger)totalRegistryRecords {
    return self->_registryRecords.count;
}

- (NSString *)debugDescription {
    NSString *description = [NSString stringWithFormat:@"totalRegistryRecords: %lu, record keys: %@",
                             (unsigned long)[self totalRegistryRecords],
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
