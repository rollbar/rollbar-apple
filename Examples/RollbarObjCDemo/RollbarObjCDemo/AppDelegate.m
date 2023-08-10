#import "AppDelegate.h"

@import RollbarNotifier;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Rollbar Configuration object.
    RollbarMutableConfig *config = [
        // Rollbar post_client_item access token
        RollbarConfig mutableConfigWithAccessToken:@"YOUR-ROLLBAR-ACCESSTOKEN"
                                       environment:@"staging"];

    config.loggingOptions.codeVersion = @"main";
    config.developerOptions.suppressSdkInfoLogging = NO;
    config.telemetry.memoryStatsAutocollectionInterval = 0.5;
    config.telemetry.enabled = YES;

    [Rollbar initWithConfiguration:config];

    [Rollbar infoMessage:@"Rollbar is up and running! Enjoy your remote error and log monitoring..."];

    return YES;
}

@end
