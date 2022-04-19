//
//  RollbarMemoryStatsDescriptors.h
//  
//
//  Created by Andrey Kornich on 2022-04-07.
//

#ifndef RollbarMemoryStatsDescriptors_h
#define RollbarMemoryStatsDescriptors_h

@import Foundation;

#pragma mark - RollbarMemoryStatsType enum

typedef NS_ENUM(NSUInteger, RollbarMemoryStatsType) {
    RollbarMemoryStatsType_Physical = 0,
    RollbarMemoryStatsType_VM,
};

#pragma mark - RollbarPhysicalMemory enum

typedef NS_ENUM(NSUInteger, RollbarPhysicalMemory) {
    RollbarPhysicalMemory_TotalMB = 0,
};

#pragma mark - RollbarVirtualMemory enum

typedef NS_ENUM(NSUInteger, RollbarVirtualMemory) {
    RollbarVirtualMemory_FreeMB = 0,
    RollbarVirtualMemory_ActiveMB,
    RollbarVirtualMemory_InactiveMB,
    RollbarVirtualMemory_SpeculativeMB,
    RollbarVirtualMemory_WiredMB
};

NS_ASSUME_NONNULL_BEGIN

#pragma mark - RollbarMemoryStatsDescriptors class

@interface RollbarMemoryStatsDescriptors : NSObject
{
}

#pragma mark - Sigleton pattern

+ (nonnull instancetype)sharedInstance;
+ (BOOL)sharedInstanceExists;

+ (instancetype)new NS_UNAVAILABLE;
+ (instancetype)allocWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;
+ (instancetype)alloc NS_UNAVAILABLE;
+ (id)copyWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;
+ (id)mutableCopyWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;
- (void)dealloc NS_UNAVAILABLE;
- (id)copy NS_UNAVAILABLE;
- (id)mutableCopy NS_UNAVAILABLE;

#pragma mark - Instance methods

- (nonnull NSString *)getMemoryStatsTypeDescriptor: (RollbarMemoryStatsType)memoryAttribute;
- (nonnull NSString *)getPhysicalMemoryDescriptor: (RollbarPhysicalMemory)memoryAttribute;
- (nonnull NSString *)getVirtualMemoryDescriptor: (RollbarVirtualMemory)memoryAttribute;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarMemoryStatsDescriptors_h
