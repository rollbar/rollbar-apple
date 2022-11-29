//
//  AppDelegate.m
//  macosAppObjC
//
//  Created by Andrey Kornich on 2020-05-21.
//  Copyright © 2020 Andrey Kornich (Wide Spectrum Computing LLC). All rights reserved.
//

#import "AppDelegate.h"
#import "RollbarDeploysDemoClient.h"

@import RollbarNotifier;
@import RollbarAUL;
@import RollbarKSCrash;
@import RollbarPLCrashReporter;

static NSString * const ROLLBAR_DEMO_PAYLOADS_ACCESS_TOKEN = @"09da180aba21479e9ed3d91e0b8d58d6";
static NSString * const ROLLBAR_DEMO_DEPLOYS_WRITE_ACCESS_TOKEN = @"efdc4b85d66045f293a7f9e99c732f61";
static NSString * const ROLLBAR_DEMO_DEPLOYS_READ_ACCESS_TOKEN = @"595cbf76b05b45f2b3ef661a2e0078d4";

__attribute__((noinline)) static void crashIt (void) {
    /* Trigger a crash */
    ((char *)NULL)[1] = 0;
}

@interface AppDelegate ()
@property (nonatomic, readonly) RollbarLogger *logger;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    // Insert code here to initialize your application
    [self initRollbar];
    
    NSData *data = [[NSData alloc] init];
    NSError *error;
    NSJSONReadingOptions serializationOptions = (NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves);
    NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:data
                                                            options:serializationOptions
                                                              error:&error];
    if (!payload && error) {
        [Rollbar log:RollbarLevel_Error
               error:error
                data:nil
             context:nil
         ];
    }
    
    @try {
        [self callTroublemaker];
    } @catch (NSException *exception) {
        [Rollbar errorException:exception data:nil context:@"from @try-@catch"];
    } @finally {
        [Rollbar infoMessage:@"Post-trouble notification!"  data:nil context:@"from @try-@finally"];
    }
    
    // now, cause a crash:
    
    [self callTroublemaker];
    @throw NSInternalInconsistencyException;
    //[self performSelector:@selector(die_die)];
    [self performSelector:NSSelectorFromString(@"crashme:") withObject:nil afterDelay:10];
    assert(NO);
    exit(0);
    crashIt();
    
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
    // Insert code here to tear down your application

    [Rollbar infoMessage:@"The hosting application is terminating..."];
}

- (void)initRollbar {

    // configure Rollbar:
    RollbarMutableConfig *config = [RollbarConfig mutableConfigWithAccessToken:ROLLBAR_DEMO_PAYLOADS_ACCESS_TOKEN
                                                                   environment:@"staging"];
    //config.developerOptions.suppressSdkInfoLogging = YES;
    config.customData = [NSMutableDictionary dictionaryWithDictionary: @{ @"someKey": @"someValue", }];
    config.telemetry.enabled = YES;
    config.telemetry.memoryStatsAutocollectionInterval = 0.5;
    config.telemetry.maximumTelemetryData = 30;

    //[RollbarAulStoreMonitor.sharedInstance configureRollbarLogger:Rollbar.currentLogger];
    [RollbarAulStoreMonitor.sharedInstance start];

    // optional crash reporter:
    id<RollbarCrashCollector> crashCollector =
      //nil;
      //[[RollbarKSCrashCollector alloc] init];
      [[RollbarPLCrashCollector alloc] init];
    
    // init Rollbar shared instance:
    [Rollbar initWithConfiguration:config crashCollector:crashCollector];
    
    [Rollbar infoMessage:@"Rollbar is up and running! Enjoy your remote error and log monitoring..."];
}

- (void)demonstrateDeployApiUsage {
    
    RollbarDeploysDemoClient * rollbarDeploysIntro = [[RollbarDeploysDemoClient new] init];
    [rollbarDeploysIntro demoDeploymentRegistration];
    [rollbarDeploysIntro demoGetDeploymentDetailsById];
    [rollbarDeploysIntro demoGetDeploymentsPage];
}

- (void)callTroublemaker {
    NSArray *items = @[@"one", @"two", @"three"];
    NSLog(@"Here is the trouble-item: %@", items[10]);
}

@end
