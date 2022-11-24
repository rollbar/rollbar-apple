//
//  RollbarOsUtil.h
//  
//
//  Created by Andrey Kornich on 2022-04-28.
//

#ifndef RollbarOsUtil_h
#define RollbarOsUtil_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RollbarOsUtil : NSObject

+ (nonnull NSString *)detectOsVersionString;
+ (NSOperatingSystemVersion)detectOsVersion;

+ (nonnull NSString *)stringFromOsVersion:(NSOperatingSystemVersion)version;

+ (NSTimeInterval)detectOsUptimeInterval;

#pragma mark - static utility nature

+ (instancetype)new NS_UNAVAILABLE;
+ (instancetype)allocWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;
+ (instancetype)alloc NS_UNAVAILABLE;
+ (id)copyWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;
+ (id)mutableCopyWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarOsUtil_h
