#import "RollbarCrashReport.h"
#import <Foundation/Foundation.h>

static NSString * const DFK_RAW = @"raw";

@implementation RollbarCrashReport

#pragma mark - Properties

- (NSString *)rawCrashReport {
    return [self safelyGetStringByKey:DFK_RAW];
}

- (void)setRawCrashReport:(NSString *)rawCrashReport {
    [self setString:rawCrashReport forKey:DFK_RAW];
}

#pragma mark - Initializers

-(instancetype)initWithRawCrashReport:(nonnull NSString *)rawCrashReport {
    
    self = [super initWithDictionary:@{
        DFK_RAW:rawCrashReport ? rawCrashReport : [NSNull null]
    }];
    return self;
}

@end
