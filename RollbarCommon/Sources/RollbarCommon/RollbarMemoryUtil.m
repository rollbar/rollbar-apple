#import "RollbarMemoryUtil.h"
#import "RollbarMemoryStatsDescriptors.h"
#import <mach/mach.h>
//#import <mach/mach_host.h>

static NSByteCountFormatter *formatter = nil;
static const NSInteger bytesInMB = 1024 * 1024;

@implementation RollbarMemoryUtil

+ (void)initialize {
    
    formatter = [[NSByteCountFormatter alloc] init];
    formatter.countStyle = NSByteCountFormatterCountStyleMemory;
    formatter.includesActualByteCount = YES;
    formatter.adaptive = YES;
    formatter.includesUnit = YES;
    formatter.zeroPadsFractionDigits = YES;
}

#pragma mark - memory stats getters

+ (nullable NSDictionary<NSString *, NSObject *> *)getPhysicalMemoryStats {
    
    return @{
        [[RollbarMemoryStatsDescriptors sharedInstance] getPhysicalMemoryDescriptor:RollbarPhysicalMemory_TotalMB] :
            [NSNumber numberWithUnsignedInteger: [RollbarMemoryUtil getPhysicalMemoryInMBs]],
    };
}

+ (nullable NSDictionary<NSString *, NSObject *> *)getVirtualMemoryStats {
    
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(
                                               mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats, &infoCount
                                               );
    if(kernReturn != KERN_SUCCESS) {
        
        return nil;
    }

    NSUInteger memoryMBs;
    
    memoryMBs = [RollbarMemoryUtil convertToMBs:(vm_page_size * vmStats.free_count)];
    NSNumber *freeMemory = [NSNumber numberWithUnsignedInteger:[RollbarMemoryUtil convertToMBs:memoryMBs]];
    
    memoryMBs = [RollbarMemoryUtil convertToMBs:(vm_page_size * vmStats.active_count)];
    NSNumber *activeMemory = [NSNumber numberWithUnsignedInteger:[RollbarMemoryUtil convertToMBs:memoryMBs]];
    
    memoryMBs = [RollbarMemoryUtil convertToMBs:(vm_page_size * vmStats.inactive_count)];
    NSNumber *inactiveMemory = [NSNumber numberWithUnsignedInteger:[RollbarMemoryUtil convertToMBs:memoryMBs]];
    
    memoryMBs = [RollbarMemoryUtil convertToMBs:(vm_page_size * vmStats.speculative_count)];
    NSNumber *speculativeMemory = [NSNumber numberWithUnsignedInteger:[RollbarMemoryUtil convertToMBs:memoryMBs]];
    
    memoryMBs = [RollbarMemoryUtil convertToMBs:(vm_page_size * vmStats.wire_count)];
    NSNumber *wiredMemory = [NSNumber numberWithUnsignedInteger:[RollbarMemoryUtil convertToMBs:memoryMBs]];

    return @{
        
        [[RollbarMemoryStatsDescriptors sharedInstance] getVirtualMemoryDescriptor:RollbarVirtualMemory_FreeMB] :
            freeMemory ? freeMemory : [NSNull null],
        [[RollbarMemoryStatsDescriptors sharedInstance] getVirtualMemoryDescriptor:RollbarVirtualMemory_ActiveMB] :
            activeMemory ? activeMemory : [NSNull null],
        [[RollbarMemoryStatsDescriptors sharedInstance] getVirtualMemoryDescriptor:RollbarVirtualMemory_InactiveMB] :
            inactiveMemory ? inactiveMemory : [NSNull null],
        [[RollbarMemoryStatsDescriptors sharedInstance] getVirtualMemoryDescriptor:RollbarVirtualMemory_SpeculativeMB] :
            speculativeMemory ? speculativeMemory : [NSNull null],
        [[RollbarMemoryStatsDescriptors sharedInstance] getVirtualMemoryDescriptor:RollbarVirtualMemory_WiredMB] :
            wiredMemory ? wiredMemory : [NSNull null],
    };
}

+ (NSUInteger)getPhysicalMemoryInBytes {
    
    unsigned long long bytesTotal = [[NSProcessInfo processInfo] physicalMemory];
    return (NSUInteger)bytesTotal;
}

#pragma mark - converters

+ (NSUInteger)convertToMBs:(NSUInteger)bytesCount {
    
    NSUInteger result = (bytesCount / bytesInMB);
    result += (bytesCount % bytesInMB);
    return result;
}

+ (NSString *)convertToHumanFriendlyFormat:(NSUInteger)bytesCount {
    
    NSString *result = [formatter stringFromByteCount:bytesCount];
    return result;
}

#pragma mark - convenience methods

+ (NSUInteger)getPhysicalMemoryInMBs {
    
    NSInteger result = [RollbarMemoryUtil convertToMBs:[RollbarMemoryUtil getPhysicalMemoryInBytes]];
    return result;
}

#pragma mark - convenience string presenters

+ (NSString *)getPhysicalMemorySizeWithUnits {
        
    NSString *result = [RollbarMemoryUtil convertToHumanFriendlyFormat:[RollbarMemoryUtil getPhysicalMemoryInBytes]];
    return result;
}

@end
