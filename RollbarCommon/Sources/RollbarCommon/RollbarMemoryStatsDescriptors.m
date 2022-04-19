#import "RollbarMemoryStatsDescriptors.h"

#pragma mark - Rollbar memorty stats related descriptors

static NSString *const Rollbar_memory_physical = @"physical";
static NSString *const Rollbar_memory_physical_totalMB = @"total_MB";

static NSString *const Rollbar_memory_vm = @"vm";
static NSString *const Rollbar_memory_vm_free = @"free_MB";
static NSString *const Rollbar_memory_vm_active = @"active_MB";
static NSString *const Rollbar_memory_vm_inactive = @"inactive_MB";
static NSString *const Rollbar_memory_vm_speculative = @"speculative_MB";
static NSString *const Rollbar_memory_vm_wired = @"wired_MB";

#pragma mark - RollbarMemoryStatsDescriptors class

static RollbarMemoryStatsDescriptors *singleton = nil;

@implementation RollbarMemoryStatsDescriptors
{
@private
    NSArray<NSString *> *memoryTypeIndex;
    NSArray<NSString *> *physicalMemoryStatsIndex;
    NSArray<NSString *> *virtualMemoryStatsIndex;
}

#pragma mark - Sigleton pattern

+ (nonnull instancetype)sharedInstance {

    //static RollbarMemoryStatsDescriptors *singleton = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        singleton = [[[self class] alloc] init];
        singleton->memoryTypeIndex = @[
            // match order of RollbarMemoryStatsType values:
            Rollbar_memory_physical,
            Rollbar_memory_vm,
        ];
        singleton->physicalMemoryStatsIndex = @[
            // match order of RollbarPhysicalMemory values:
            Rollbar_memory_physical_totalMB,
        ];
        singleton->virtualMemoryStatsIndex = @[
            // match order of RollbarVirtualMemory values:
            Rollbar_memory_vm_free,
            Rollbar_memory_vm_active,
            Rollbar_memory_vm_inactive,
            Rollbar_memory_vm_speculative,
            Rollbar_memory_vm_wired,
        ];
    });
    
    return singleton;
}

+ (BOOL)sharedInstanceExists {
        
    return (nil != singleton);
}

#pragma mark - Instance methods

- (nonnull NSString *)getMemoryStatsTypeDescriptor: (RollbarMemoryStatsType)memoryAttribute {

    return self->memoryTypeIndex[memoryAttribute];
}

- (nonnull NSString *)getPhysicalMemoryDescriptor: (RollbarPhysicalMemory)memoryAttribute {
    
    return self->physicalMemoryStatsIndex[memoryAttribute];
}

- (nonnull NSString *)getVirtualMemoryDescriptor: (RollbarVirtualMemory)memoryAttribute {
    
    return self->virtualMemoryStatsIndex[memoryAttribute];
}

@end
