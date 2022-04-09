//
//  RollbarMemoryUtil.h
//
//
//  Created by Andrey Kornich on 2022-04-07.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface RollbarMemoryUtil : NSObject


#pragma mark - memory stats getters

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


@end

NS_ASSUME_NONNULL_END
