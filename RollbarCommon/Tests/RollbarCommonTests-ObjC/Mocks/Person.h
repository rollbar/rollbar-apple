//
//  Person.h
//  
//
//  Created by Andrey Kornich on 2021-04-29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

@property (readonly) NSString *firstName;
@property (readonly) NSString *lastName;
@property (readonly) NSDate *birthDate;
@property (readonly) NSInteger age;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithFirstName:(NSString *)firstName
                         lastName:(NSString *)lastName
                             adge:(NSInteger)age
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithFirstName:(NSString *)firstName
                         lastName:(NSString *)lastName
                        birthDate:(NSDate *)birthDate
NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
