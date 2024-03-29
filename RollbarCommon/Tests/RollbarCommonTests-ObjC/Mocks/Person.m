//
//  Person.m
//  
//
//  Created by Andrey Kornich on 2021-04-29.
//

#import "Person.h"

@implementation Person

- (instancetype)initWithFirstName:(NSString *)firstName
                         lastName:(NSString *)lastName
                              age:(NSInteger)age {
    
    self = [super init];
    if (self == nil) {
        return nil;
    }

    _firstName = firstName;
    _lastName = lastName;
    _age = age;
    
    return self;
}

- (instancetype)initWithFirstName:(NSString *)firstName
                         lastName:(NSString *)lastName
                        birthDate:(NSDate *)birthDate {
    
    self = [super init];
    if (self == nil) {
        return nil;
    }

    _firstName = firstName;
    _lastName = lastName;
    _birthDate = birthDate;
    
    return self;
}

- (instancetype)initWithFirstName:(NSString *)firstName
                         lastName:(NSString *)lastName
                              ssn:(NSNumber *)ssn {
    
    self = [super init];
    if (self == nil) {
        return nil;
    }

    _firstName = firstName;
    _lastName = lastName;
    _ssn = ssn;
    
    return self;
}


@end
