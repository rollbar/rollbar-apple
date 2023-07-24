#import "RollbarDestinationRecord.h"
#import "RollbarRegistry.h"
#import "RollbarInfrastructure.h"
#import "RollbarInternalLogging.h"

@implementation RollbarDestinationRecord {
    @private
}

#pragma mark - property accessors

- (RollbarRateLimitBehavior)rateLimitBehavior {
    return RollbarInfrastructure.sharedInstance.configuration.loggingOptions.rateLimitBehavior;
}

#pragma mark - initializers

- (instancetype)initWithConfig:(nonnull RollbarConfig *)config
                   andRegistry:(nonnull RollbarRegistry *)registry {
    
    NSAssert(config, @"Config can not be nil!");
    NSAssert(config.destination, @"Config destination can not be nil!");
    NSAssert(registry, @"Registry can not be nil!");
    
    if (self = [super init]) {
        
        self->_registry = registry;
        self->_destinationID = [RollbarRegistry destinationID:config.destination];
        self->_localWindowLimit = config.loggingOptions.maximumReportsPerMinute;
        self->_localWindowCount = 0;
        self->_serverWindowRemainingCount = 0;
        self->_nextLocalWindowStart = nil;
        self->_nextServerWindowStart = nil;
        self->_nextEarliestPost = [NSDate date];
    }
    return self;
}

- (instancetype)initWithDestinationID:(nonnull NSString *)destinationID
                          andRegistry:(nonnull RollbarRegistry *)registry {
    
    if (self = [super init]) {
        
        self->_registry = registry;
        self->_destinationID = destinationID;
        self->_localWindowLimit = 0;
        self->_localWindowCount = 0;
        self->_serverWindowRemainingCount = 0;
        self->_nextLocalWindowStart = nil;
        self->_nextServerWindowStart = nil;
        self->_nextEarliestPost = [NSDate date];
    }
    return self;
}

#pragma mark - methods

- (BOOL)canPostWithConfig:(nonnull RollbarConfig *)config {
    if (self->_nextLocalWindowStart && (self->_localWindowCount >= config.loggingOptions.maximumReportsPerMinute)) {
        // we already exceeded local rate limits, let's wait till the next local rate limiting window:
        //self->_nextEarliestPost = self->_nextLocalWindowStart;
        return NO;
    }

    if (!self->_nextEarliestPost) {
        return NO;
    }

    BOOL shouldPost = [self->_nextEarliestPost compare:[NSDate date]] != NSOrderedDescending;

    if (shouldPost) {
        RBLog(@"Rate limit %@ ≤ %@ :: GO", self->_nextEarliestPost, [NSDate date]);
    }

    return shouldPost;
}

- (void)recordPostReply:(nullable RollbarPayloadPostReply *)reply
             withConfig:(nonnull RollbarConfig *)config
{
    if (!reply) {
        //no response from the server to our lates POST of a payload,
        //let's hold on on posting to the destination for 1 minute:
        self->_nextEarliestPost = [NSDate dateWithTimeIntervalSinceNow:60];
        self->_localWindowCount = 0;
        self->_serverWindowRemainingCount = 0;
        self->_nextLocalWindowStart = self->_nextEarliestPost;
        self->_nextServerWindowStart = nil;
        return; // nothing else to do...
    }
    
    switch (reply.statusCode) {
        case 401: // unauthorized
        case 403: // access denied
        case 404: // not found
            RBLog(@"\tQueuing record");
            // let's hold on on posting to the destination for 1 minute:
            self->_nextEarliestPost = [NSDate dateWithTimeIntervalSinceNow:60];
            self->_localWindowCount = 0;
            self->_serverWindowRemainingCount = 0;
            self->_nextLocalWindowStart = self->_nextEarliestPost;
            self->_nextServerWindowStart = nil;
            return; // nothing else to do...
        case 429: // too many requests
            if (self.rateLimitBehavior == RollbarRateLimitBehavior_Queue) {
                RBLog(@"\tQueuing record");
                self->_nextLocalWindowStart = [NSDate dateWithTimeIntervalSinceNow:reply.remainingSeconds];
                self->_serverWindowRemainingCount = 0;
                break;
            }
        case 200: // OK
        case 400: // bad request
        case 413: // request entity too large
        case 422: // unprocessable entity
        default:
            RBLog(@"\tDropping record");
            self->_nextServerWindowStart = [NSDate dateWithTimeIntervalSinceNow:reply.remainingSeconds];
            self->_serverWindowRemainingCount = reply.remainingCount;
            if (self->_nextLocalWindowStart) {
                self->_localWindowCount = 0;
                self->_nextLocalWindowStart = [NSDate dateWithTimeIntervalSinceNow:60];
            } else {
                self->_localWindowCount += 1;
            }
            break;
    }

    // since we got here, let's calculate value for self->_nextEarliestPost:
    
    if (self->_nextServerWindowStart && (0 == self->_serverWindowRemainingCount)) {
        // server told us to wait until next rate limiting window:
        self->_nextEarliestPost = self->_nextServerWindowStart;
        return;
    }
    
    if (self->_nextLocalWindowStart && (self->_localWindowCount >= self->_localWindowLimit)) {
        // we already exceeded local rate limits, let's wait till the next local rate limiting window:
        self->_nextEarliestPost = self->_nextLocalWindowStart;
        return;
    }
    
    // looks like no limits are in force now, keep sending ASAP:
    self->_nextEarliestPost = [NSDate date];
    return;
}

#pragma mark - overrides

- (nonnull NSString *)description {
    NSString *description = [NSString stringWithFormat:@"%@:\n"
                             "   destinationID:              %@\n"
                             "   localWindowLimit:           %lu\n"
                             "   localWindowCount:           %lu\n"
                             "   serverWindowRemainingCount: %lu\n"
                             "   nextLocalWindowStart:       %@\n"
                             "   nextServerWindowStart:      %@\n"
                             "   nextEarliestPost:           %@\n"
                             ,
                             super.description,
                             self->_destinationID,
                             self->_localWindowLimit,
                             self->_localWindowCount,
                             self->_serverWindowRemainingCount,
                             self->_nextLocalWindowStart,
                             self->_nextServerWindowStart,
                             self->_nextEarliestPost];
    return description;
}

@end
