//
//  RollbarSession.m
//  
//
//  Created by Andrey Kornich on 2022-04-21.
//

#import "RollbarSession.h"
#import "RollbarSessionState.h"
#import "RollbarLogger.h"
#import "Rollbar.h"
#import <sys/stat.h>

@import RollbarCommon;

#if __has_include(<WatchKit/WatchKit.h>)
#import <WatchKit/WatchKit.h>
#define __HAS_WATCHKIT_FRAMEWORK__
#elif __has_include(<TVUIKit/TVUIKit.h>)
#import <TVUIKit/TVUIKit.h>
#define __HAS_TVUIKIT_FRAMEWORK__
#elif __has_include(<UIKit/UIKit.h>)
#import <UIKit/UIKit.h>
#define __HAS_UIKIT_FRAMEWORK__
#elif __has_include(<AppKit/AppKit.h>)
#import <AppKit/AppKit.h>
#define __HAS_APPKIT_FRAMEWORK__
#endif

static NSString * const SESSION_FILE_NAME = @"rollbar.session";
static NSString * const APP_QUIT_FILE_NAME = @"rollbar.appquit";

static char *appQuitFilePath;

@implementation RollbarSession {
    
@private
    RollbarSessionState *_state;
    NSString *_stateFilePath;
    RollbarCrashReportCheck _crashLocator;
}

- (void)enableOomMonitoringWithCrashCheck:(nullable RollbarCrashReportCheck)crashCheck {
    
    self->_crashLocator =
    crashCheck ? crashCheck : [self registerDefaultCrashCheck];
    
    if (YES == [RollbarCachesDirectory ensureCachesDirectoryExists]) {
        appQuitFilePath = strdup([[RollbarCachesDirectory getCacheFilePath:APP_QUIT_FILE_NAME] UTF8String]);
    }
    
    [self deduceOomTermination];
    
    self->_state.osUptimeInterval = [RollbarOsUtil detectOsUptimeInterval];
    self->_state.osVersion = [RollbarOsUtil detectOsVersionString];
    self->_state.appVersion = [RollbarBundleUtil detectAppBundleVersion];
    // self->_state.appID = NOTE: we do not want to ever override this value...
    self->_state.sessionID = [NSUUID new];
    self->_state.sessionStartTimestamp = [NSDate date];
    self->_state.appMemoryWarningTimestamp = nil;
    self->_state.appTerminationTimestamp = nil;
    self->_state.sysSignal = nil;
    self->_state.appCrashDetails = nil;
    self->_state.appInBackgroundFlag = RollbarTriStateFlag_None;
    
    [self saveCurrentSessionState];
    
    [self registerForSystemSignals];
    [self registerApplicationHooks];
}

- (void)deduceOomTermination {
    
    RollbarSdkLog(@"Deducing OOOM Termination based on: %@", self->_state);
    
    BOOL appQuit = NO;
    struct stat statbuffer;
    if (stat(appQuitFilePath, &statbuffer) == 0){
        // A file exists at the path, we had an intentional quit
        appQuit = YES;
    }
    if (YES == appQuit) {

        NSString *message = @"The app was exited at the end of last session.";
        [Rollbar infoMessage:message data:self->_state.jsonFriendlyData];
        return;
    }
    
    BOOL appUpgraded = [self didAppVersionChange:self->_state.appVersion];
    if (YES == appUpgraded) {
        
        NSString *message = [NSString stringWithFormat:@"The app was upgraded from %@ to %@",
                             self->_state.appVersion,
                             [RollbarBundleUtil detectAppBundleVersion]
        ];
        [Rollbar infoMessage:message data:self->_state.jsonFriendlyData];
        return;
    }
    
    BOOL appTerminated = (nil != self->_state.appTerminationTimestamp) ? YES : NO;
    if (YES == appTerminated) {
        
        NSString *message = [NSString stringWithFormat:@"The app was terminated at %@",
                             self->_state.appTerminationTimestamp
        ];
        RollbarSdkLog(@"%@", message);
        [Rollbar infoMessage:message data:self->_state.jsonFriendlyData];
        return;
    }
    
    BOOL appCrashed = self->_crashLocator();
    if (YES == appCrashed) {
        
        NSString *message = @"The app had a crash.";
        RollbarSdkLog(@"%@", message);
        [Rollbar criticalMessage:message data:self->_state.jsonFriendlyData context:self->_state.appCrashDetails];
        return;
    }
    
    BOOL osUpgraded = [self didOsVersionChange:self->_state.osVersion];
    if (YES == osUpgraded) {
        
        NSString *message = [NSString stringWithFormat:@"The OS was upgraded from %@ to %@",
                             self->_state.osVersion,
                             [RollbarOsUtil detectOsVersionString]
        ];
        RollbarSdkLog(@"%@", message);
        [Rollbar infoMessage:message data:self->_state.jsonFriendlyData];
        return;
    }
    
    NSString *oomContext = nil;
    switch (self->_state.appInBackgroundFlag) {
            
        case RollbarTriStateFlag_On:
            oomContext = @"BOOM";
            break;
        case RollbarTriStateFlag_Off:
            oomContext = @"FOOM";
            break;
        case RollbarTriStateFlag_None:
        default:
            oomContext = @"the app background state is unknown";
            break;
    }
    NSString *message =
    [NSString stringWithFormat:
     @"The app possibly was recycled due to Out-of-Memory problem (%@).", oomContext
    ];
    RollbarSdkLog(@"%@", message);
    [Rollbar warningMessage:message data:self->_state.jsonFriendlyData];
    
    unlink(appQuitFilePath);
}

- (RollbarCrashReportCheck)registerDefaultCrashCheck {
    
    if (NSGetUncaughtExceptionHandler()) {
        RollbarSdkLog(@"!!!: It looks like your application has already set an uncaught exception handler."
                      "Are you using some kind of crash reporting library?"
                      "This will disable that code. If you would like to use that crash reporting library "
                      "side-by-side with Rollbar OOM detection, make sure you pass a crashCheck block to "
                      "enableOomMonitoringWithCrashCheck: method call that uses your crash reporting library's "
                      "crashCheck equivalent."
                      );
    }
    
    NSSetUncaughtExceptionHandler(&defaultExceptionHandler);
    
    return [self defaultCrashCheck];
}

static void defaultExceptionHandler(NSException *exception) {
    
    NSArray *backtrace = [exception callStackSymbols];
    NSString *appVersion = [RollbarBundleUtil detectAppBundleVersion];
    NSString *osVersion = [RollbarOsUtil detectOsVersionString];
    NSString *exceptionDetails = [NSString stringWithFormat:@"App: %@. \nOS: %@. \nBacktrace: \n%@",
                                  appVersion,
                                  osVersion,
                                  backtrace
    ];
    NSString *rollbarCrashDetails = [NSString stringWithFormat:@"Uncaught exception: %@\n Details: \n%@\n",
                                    exception,
                                    exceptionDetails
    ];

    [[RollbarSession sharedInstance] captureAppCrashDetails:rollbarCrashDetails
                                              withException:exception
    ];
}

- (void)captureAppCrashDetails:(nonnull NSString *)crashDetails
                 withException:(NSException *)exception {
    
    self->_state.appCrashDetails = crashDetails;
    
    [self saveCurrentSessionState];

    [Rollbar criticalException:exception
                          data:self->_state.jsonFriendlyData
                       context:crashDetails
    ];
}

- (RollbarCrashReportCheck)defaultCrashCheck {
    
    return ^() {
        
        if (self->_state.appCrashDetails) {
            
            return YES;
        }
        else {
            
            return NO;
        }
    };
}

#pragma mark - System and Application notification hooks

- (void)registerForSystemSignals {
    
    signal(SIGABRT, onSysSignal);
    signal(SIGQUIT, onSysSignal);
    signal(SIGTERM, onSysSignal);
}

static void onSysSignal(int signalID) {
    
    creat(appQuitFilePath, S_IREAD | S_IWRITE);
    
    NSString *signalDescriptor = nil;
    switch(signalID) {
        case SIGABRT:
            signalDescriptor = @"SIGABRT";
            break;
        case SIGQUIT:
            signalDescriptor = @"SIGQUIT";
            break;
        case SIGTERM:
            signalDescriptor = @"SIGTERM";
            break;
        default:
            return;
    }
    [[RollbarSession sharedInstance] captureSystemSignal:signalDescriptor];
}

- (void)captureSystemSignal:(nonnull NSString *)signal {
    
    self->_state.sysSignal = signal;
    [self saveCurrentSessionState];
}

- (void)registerApplicationHooks {
    
#if defined(__HAS_WATCHKIT_FRAMEWORK__)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationInForeground:)
                                                 name:WKApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationInBackground:)
                                                 name:WKApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationTerminated:)
                                                 name:WKApplicationWillResignActiveNotification
                                               object:nil];
#elif defined(__HAS_TVUIKIT_FRAMEWORK__)


#elif defined(__HAS_UIKIT_FRAMEWORK__)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationInForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationInBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationTerminated:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationReceivedMemoryWarning:)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];

    
#elif defined(__HAS_APPKIT_FRAMEWORK__)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationInForeground:)
                                                 name:NSApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationInBackground:)
                                                 name:NSApplicationDidResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationTerminated:)
                                                 name:NSApplicationWillTerminateNotification
                                               object:nil];
#endif
}

- (void)applicationInForeground:(NSNotification *)notification {
    
    self->_state.appInBackgroundFlag = RollbarTriStateFlag_Off;
    [self saveCurrentSessionState];
}

- (void)applicationInBackground:(NSNotification *)notification {

    self->_state.appInBackgroundFlag = RollbarTriStateFlag_On;
    [self saveCurrentSessionState];
}

- (void)applicationTerminated:(NSNotification *)notification {

    self->_state.appTerminationTimestamp = [NSDate date];
    [self saveCurrentSessionState];
}

- (void)applicationReceivedMemoryWarning:(NSNotification *)notification {

    self->_state.appMemoryWarningTimestamp = [NSDate date];
    [self saveCurrentSessionState];
    
    [Rollbar warningMessage:@"The app received a memory warning."
                       data:self->_state.jsonFriendlyData
    ];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - app/OS version change checks

- (BOOL)didAppVersionChange:(nonnull NSString *)oldVersion {
    
    BOOL result = ![[RollbarBundleUtil detectAppBundleVersion] isEqualToString:oldVersion];
    return result;
}

- (BOOL)didOsVersionChange:(nonnull NSString *)oldVersion {
    
    BOOL result = ![[RollbarOsUtil detectOsVersionString] isEqualToString:oldVersion];
    return result;
}

#pragma mark - state access

- (RollbarSessionState *)getCurrentState {
  
    NSString *json = [self->_state serializeToJSONString];
    RollbarSessionState *stateClone = [[RollbarSessionState alloc] initWithJSONString:json];
    return stateClone;
}

#pragma mark - Sigleton pattern

+ (nonnull instancetype)sharedInstance {
    
    static id singleton;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        singleton = [self new];
    });
    
    return singleton;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        self->_stateFilePath = [RollbarCachesDirectory getCacheFilePath:SESSION_FILE_NAME];
        
        if (NO == [RollbarCachesDirectory ensureCachesDirectoryExists]) {
            
            RollbarSdkLog(@"Failed to create the Rollbar Caches Directory!");
            return self;
        }
        
        if (YES == [RollbarCachesDirectory checkCacheFileExists:SESSION_FILE_NAME]) {
            
            self->_state = [self loadSessionState];
        }
        else {

            self->_state = [RollbarSessionState new];
            [self saveCurrentSessionState];
        }
    }
    return self;
}

#pragma mark - session state persistence

- (RollbarSessionState *)loadSessionState {
   
    NSData *data = [[NSData alloc] initWithContentsOfFile:self->_stateFilePath];
    RollbarSessionState *state = [[RollbarSessionState alloc] initWithJSONData:data];
    return state;
}

- (BOOL)saveSessionState:(nonnull RollbarSessionState *)state {
    
    NSError *error;
    NSData *data = [NSJSONSerialization rollbar_dataWithJSONObject:state.jsonFriendlyData
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error
                                                              safe:true];
    if (!data && error) {
        RollbarSdkLog(@"Error saving Rollbar Session State: %@ !!!", [error localizedDescription]);
    }
    [data writeToFile:self->_stateFilePath atomically:YES];
}

- (BOOL)saveCurrentSessionState {
    
    return [self saveSessionState:self->_state];
}

@end
