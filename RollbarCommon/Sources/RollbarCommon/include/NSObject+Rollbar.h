//
//  NSObject+Rollbar.h
//  
//
//  Created by Andrey Kornich on 2021-04-23.
//

#ifndef NSObject_Rollbar_h
#define NSObject_Rollbar_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Rollbar category for NSObject
@interface NSObject (Rollbar)

/// Returns object's class name
- (nonnull NSString *)rollbar_objectClassName;

@end

NS_ASSUME_NONNULL_END

#endif //NSObject_Rollbar_h
