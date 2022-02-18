#import "RollbarMessage.h"
#import <Foundation/Foundation.h>

static NSString * const DFK_BODY = @"body";

@implementation RollbarMessage

#pragma mark - properties

- (NSString *)body {
    return [self safelyGetStringByKey:DFK_BODY];
}

- (void)setBody:(NSString *)messageBody {
    [self setString:messageBody forKey:DFK_BODY];
}

#pragma mark - Initializers

-(instancetype)initWithBody:(nonnull NSString *)messageBody {
    
    self = [super initWithDictionary:@{
        DFK_BODY:messageBody ? messageBody : [NSNull null]
    }];
    return self;
}

-(instancetype)initWithNSError:(nonnull NSError *)error {
    
    NSString *messageBody = [NSString stringWithFormat:@"NSError: %@", error.description];
    self = [super initWithDictionary:@{
        DFK_BODY:messageBody ? messageBody : [NSNull null],
        @"error_code": [NSNumber numberWithInteger:error.code],
        @"error_domain": error.domain,
        @"error_help_anchor": error.helpAnchor ? error.helpAnchor :[NSNull null],
        @"error_user_info": [RollbarDTO isTransferableObject: error.userInfo] ? error.userInfo : [NSNull null]
    }];
    return self;
}


@end
