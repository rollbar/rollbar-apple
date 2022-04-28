//
//  NSDate+Rollbar.h
//  
//
//  Created by Andrey Kornich on 2022-04-27.
//

#ifndef NSDate_Rollbar_h
#define NSDate_Rollbar_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate(Rollbar)

+ (nullable NSDate *)rollbar_dateFromString:(nonnull NSString *)dateString;
- (nonnull NSString *)rollbar_toString;

@end

NS_ASSUME_NONNULL_END

#endif //NSObject_Rollbar_h
