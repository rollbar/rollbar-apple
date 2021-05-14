//
//  NSObject+Rollbar.h
//  
//
//  Created by Andrey Kornich on 2021-04-23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Rollbar category for NSObject
@interface NSObject (Rollbar)

/// Returns object's class name
- (nonnull NSString *)rollbar_objectClassName;

@end

NS_ASSUME_NONNULL_END
