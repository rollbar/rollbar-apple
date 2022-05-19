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

#pragma mark - utility

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarOsUtil_h
