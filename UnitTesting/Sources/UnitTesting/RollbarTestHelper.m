#import "RollbarTestHelper.h"
#import "RollbarUnitTestSettings.h"

@implementation RollbarTestHelper

+ (nonnull NSString *)getRollbarEnvironment {
    
    return ROLLBAR_UNIT_TEST_ENVIRONMENT;
}

+ (nonnull NSString *)getRollbarPayloadsAccessToken {
    
    return ROLLBAR_UNIT_TEST_PAYLOADS_ACCESS_TOKEN;
}

+ (nonnull NSString *)getRollbarDeploysWriteAccessToken {
    
    return ROLLBAR_UNIT_TEST_DEPLOYS_WRITE_ACCESS_TOKEN;
}

+ (nonnull NSString *)getRollbarDeploysReadAccessToken {
    
    return ROLLBAR_UNIT_TEST_DEPLOYS_READ_ACCESS_TOKEN;
}

@end
