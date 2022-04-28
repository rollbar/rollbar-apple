//
//  NSDate+Rollbar.m
//  
//
//  Created by Andrey Kornich on 2022-04-27.
//

#import "NSDate+Rollbar.h"

@implementation NSDate(Rollbar)

+ (nullable NSDate *)rollbar_dateFromString:(nonnull NSString *)dateString {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd 'at' HH:mm:ss.SSSSSSXX"];
    NSDate *date = [formatter dateFromString:dateString];
    return date;
}

- (nonnull NSString *)rollbar_toString {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd 'at' HH:mm:ss.SSSSSSXX"];
    NSString *dateString = [formatter stringFromDate:self];
    return dateString;
}

@end
