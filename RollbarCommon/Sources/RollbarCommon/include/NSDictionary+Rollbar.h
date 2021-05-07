//
//  MyClass.h
//  
//
//  Created by Andrey Kornich on 2020-09-30.
//

#ifndef NSDictionary_Rollbar_h
#define NSDictionary_Rollbar_h

@import Foundation;

/// Rollbar category for NSDictionary
@interface NSDictionary (Rollbar)

NS_ASSUME_NONNULL_BEGIN

/// Checks if a value of the specified class type peresent for the specified key
/// @param key <#key description#>
/// @param className <#className description#>
- (BOOL)rollbar_valuePresentForKey:(nonnull NSString *)key
                         className:(nullable NSString *)className;

NS_ASSUME_NONNULL_END

@end

#endif //NSDictionary_Rollbar_h
