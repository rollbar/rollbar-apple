//
//  RollbarMemoryUtil.h
//
//
//  Created by Andrey Kornich on 2022-04-07.
//

#ifndef RollbarMemoryUtil_h
#define RollbarMemoryUtil_h

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface RollbarMemoryUtil : NSObject

#pragma mark - memory stats getters

+ (nonnull NSDictionary<NSString *, NSObject *> *)getMemoryStats;
+ (nullable NSDictionary<NSString *, NSObject *> *)getPhysicalMemoryStats;
+ (nullable NSDictionary<NSString *, NSObject *> *)getVirtualMemoryStats;
+ (NSUInteger)getPhysicalMemoryInBytes;

#pragma mark - converters

+ (NSUInteger)convertToMBs:(NSUInteger)bytesCount;
+ (NSString *)convertToHumanFriendlyFormat:(NSUInteger)bytesCount;

#pragma mark - convenience methods

+ (NSUInteger)getPhysicalMemoryInMBs;

#pragma mark - convenience string presenters

+ (NSString *)getPhysicalMemorySizeWithUnits;

#pragma mark - static utility nature

+ (instancetype)new NS_UNAVAILABLE;
+ (instancetype)allocWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;
+ (instancetype)alloc NS_UNAVAILABLE;
+ (id)copyWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;
+ (id)mutableCopyWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarMemoryUtil_h
