//
//  RollbarHostingProcessUtil.h
//  
//
//  Created by Andrey Kornich on 2021-05-05.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Rollbar utility for getting process related details/attributes
@interface RollbarHostingProcessUtil : NSObject

/// Returns current process's name
+ (NSString *)getHostingProcessName;

/// Returns current process's ID
+ (int)getHostingProcessIdentifier;

@end

NS_ASSUME_NONNULL_END
