#import "RollbarPayloadPostReply.h"

/// Rollbar API Service enforced payload rate limit:
static NSString * const RESPONSE_HEADER_RATE_LIMIT = @"x-rate-limit-limit";
/// Rollbar API Service enforced remaining payload count until the limit is reached:
static NSString * const RESPONSE_HEADER_REMAINING_COUNT = @"x-rate-limit-remaining";
/// Rollbar API Service enforced rate limit reset time for the current limit window:
static NSString * const RESPONSE_HEADER_RESET_TIME = @"x-rate-limit-reset";
/// Rollbar API Service enforced rate limit remaining seconds of the current limit window:
static NSString * const RESPONSE_HEADER_REMAINING_SECONDS = @"x-rate-limit-remaining-seconds";

@implementation RollbarPayloadPostReply

+ (nullable RollbarPayloadPostReply *)replyFromHttpResponse:(nonnull NSHTTPURLResponse *)httpResponse {
    
    NSUInteger rateLimit =
    [NSNumber numberWithLongLong:[httpResponse valueForHTTPHeaderField:RESPONSE_HEADER_RATE_LIMIT]]
        .unsignedIntegerValue;

    NSUInteger remainingCount =
    [NSNumber numberWithLongLong:[httpResponse valueForHTTPHeaderField:RESPONSE_HEADER_REMAINING_COUNT]]
        .unsignedIntegerValue;

    NSUInteger remainingSeconds =
    [NSNumber numberWithLongLong:[httpResponse valueForHTTPHeaderField:RESPONSE_HEADER_REMAINING_SECONDS]]
        .unsignedIntegerValue;
    
    return [[RollbarPayloadPostReply alloc] initWithStatusCode:httpResponse.statusCode
                                                     rateLimit:rateLimit
                                                remainingCount:remainingCount
                                              remainingSeconds:remainingSeconds
    ];
}

- (instancetype)initWithStatusCode:(NSUInteger)statusCode
                         rateLimit:(NSUInteger)rateLimit
                    remainingCount:(NSUInteger)remainingCount
                  remainingSeconds:(NSUInteger)remainingSeconds {
    
    if (self = [super init]) {
        self->_statusCode = statusCode;
        self->_rateLimit = rateLimit;
        self->_remainingCount = remainingCount;
        self->_remainingSeconds = remainingSeconds;
        
        if (self->_remainingCount > 0) {
            self->_nextPostTime = [[NSDate alloc] init];
        }
        else {
            self->_nextPostTime = [[NSDate alloc] initWithTimeIntervalSinceNow:self->_remainingSeconds];
        }
    }
    
    return self;
}

+ (nonnull RollbarPayloadPostReply *)greenReply {

    return [[RollbarPayloadPostReply alloc] initWithStatusCode:200
                                                     rateLimit:1
                                                remainingCount:1
                                              remainingSeconds:1
    ];
}

+ (nonnull RollbarPayloadPostReply *)redReply {
    
    return [[RollbarPayloadPostReply alloc] initWithStatusCode:200
                                                     rateLimit:1
                                                remainingCount:0
                                              remainingSeconds:1
    ];
}


@end
