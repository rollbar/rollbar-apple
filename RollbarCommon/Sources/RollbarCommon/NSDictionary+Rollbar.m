#import "NSDictionary+Rollbar.h"
#import "RollbarInternalLogging.h"

@implementation NSDictionary (Rollbar)

NS_ASSUME_NONNULL_BEGIN

- (BOOL)rollbar_valuePresentForKey:(nonnull NSString *)key
                       withContext:(nullable NSString *)context {

    id value = self[key];
    if (nil != value) {
        if ((id)[NSNull null] != value) {
            return YES;
        }
        else {
            RBCErr(@"[%@] - key %@ has no value", context, key);
        }
    }
    else {
        RBCErr(@"[%@] - key %@ not found", context, key);
    }
    
    return NO;
}

NS_ASSUME_NONNULL_END

@end
