//
//  RollbarFileIOUtil.h
//  
//
//  Created by Andrey Kornich on 2022-06-01.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RollbarFileIOUtil : NSObject

+ (nullable NSURL *)applicationSupportDirectory;
+ (nullable NSURL *)applicationCachesDirectory;

@end

NS_ASSUME_NONNULL_END
