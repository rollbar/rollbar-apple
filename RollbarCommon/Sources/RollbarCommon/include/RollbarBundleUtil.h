//
//  RollbarBundleUtil.h
//  
//
//  Created by Andrey Kornich on 2022-04-28.
//

#ifndef RollbarBundleUtil_h
#define RollbarBundleUtil_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RollbarBundleUtil : NSObject

+ (nonnull NSString *)detectAppBundleVersion;

#pragma mark - utility

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarBundleUtil_h
