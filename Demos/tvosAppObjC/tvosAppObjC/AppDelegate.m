//
//  AppDelegate.m
//  tvosAppObjC
//
//  Created by Andrey Kornich on 2022-04-26.
//

#import "AppDelegate.h"

@import RollbarNotifier;
@import RollbarKSCrash;
@import RollbarPLCrashReporter;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

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
    //    [self callTroublemaker];
    
    //@throw NSInternalInconsistencyException;
    
    //    [self performSelector:@selector(die_die)];
    //    [self performSelector:NSSelectorFromString(@"crashme:") withObject:nil afterDelay:10];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)initRollbar {
    
    // configure Rollbar:
    RollbarMutableConfig *config = [RollbarConfig mutableConfigWithAccessToken:@"09da180aba21479e9ed3d91e0b8d58d6"
                                                                   environment:@"staging"];
    
    config.developerOptions.suppressSdkInfoLogging = YES;
    config.telemetry.memoryStatsAutocollectionInterval = 0.5;
    config.telemetry.enabled = YES;
    //config.customData = @{ @"someKey": @"someValue", };
    
    // init Rollbar shared instance:
    //id<RollbarCrashCollector> crashCollector = [[RollbarKSCrashCollector alloc] init];
    id<RollbarCrashCollector> crashCollector = [[RollbarPLCrashCollector alloc] init];
    
    [Rollbar initWithConfiguration:config crashCollector:crashCollector];
    
    [Rollbar infoMessage:@"Rollbar is up and running! Enjoy your remote error and log monitoring..."];
}

- (void)callTroublemaker {
    NSArray *items = @[@"one", @"two", @"three"];
    NSLog(@"Here is the trouble-item: %@", items[10]);
}

@end
