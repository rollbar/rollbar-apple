//
//  NSObject+Rollbar.h
//  
//
//  Created by Andrey Kornich on 2021-04-23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Rollbar)

- (nonnull NSString *)objectClassName;

@end

NS_ASSUME_NONNULL_END
