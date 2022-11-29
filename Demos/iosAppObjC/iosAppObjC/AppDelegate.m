#import "AppDelegate.h"

@import RollbarNotifier;
@import RollbarKSCrash;
@import RollbarPLCrashReporter;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    RollbarMutableConfig *config = [RollbarConfig mutableConfigWithAccessToken:@"dc0d9ce3d93c4ef5a4dbacf2434e508d"
                                                                   environment:@"staging"];
    config.loggingOptions.codeVersion = @"main";
    config.developerOptions.suppressSdkInfoLogging = NO;
    config.telemetry.memoryStatsAutocollectionInterval = 0.5;
    config.telemetry.enabled = YES;

    //id<RollbarCrashCollector> crashCollector = [[RollbarKSCrashCollector alloc] init];
    id<RollbarCrashCollector> crashCollector = [[RollbarPLCrashCollector alloc] init];

    [Rollbar initWithConfiguration:config
                    crashCollector:crashCollector];

    [Rollbar infoMessage:@"Rollbar is up and running! Enjoy your remote error and log monitoring..."];

    return YES;
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *) application:(UIApplication *)application
configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession
                               options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration"
                                          sessionRole:connectingSceneSession.role];
}

@end
