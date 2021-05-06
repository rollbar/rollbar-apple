//
//  RollbarHostingProcessUtil.h
//  
//
//  Created by Andrey Kornich on 2021-05-05.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RollbarHostingProcessUtil : NSObject

+ (NSString *)getHostingProcessName;

+ (int)getHostingProcessIdentifier;

@end

NS_ASSUME_NONNULL_END
