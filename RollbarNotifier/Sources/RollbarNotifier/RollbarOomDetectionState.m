//
//  RollbarOomDetectionState.m
//  
//
//  Created by Andrey Kornich on 2022-04-21.
//

#import "RollbarOomDetectionState.h"
#import <TargetConditionals.h>

//#if TARGET_OS_IPHONE
//#if TARGET_OS_WATCH
//@import SwiftUI;
//#else
//@import UIKit;
//#endif
//#else
//@import AppKit;
//#endif

//@import SwiftUI;
//#if !TARGET_OS_IPHONE && !TARGET_OS_WATCH
//@import AppKit;
//#endif

//@import SwiftUI;

#if TARGET_OS_WATCH
@import WatchKit;
#elif TARGET_OS_TV
@import TVUIKit;
#elif TARGET_OS_IOS
@import UIKit;
#else
@import AppKit;
#endif

@implementation RollbarOomDetectionState

#pragma mark - OS attributes detection


#pragma mark - Application attributes detection


#pragma mark - Application notification hooks

- (void)registerApplicationHooks {

#if TARGET_OS_WATCH

    // when with WatchKit:
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationInForeground)
                                                 name:WKApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationInBackground)
                                                 name:WKApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationTerminated)
                                                 name:WKApplicationWillResignActiveNotification
                                               object:nil];

    //WKExtension.applicationWillEnterForegroundNotification
    //WKApplicationDidBecomeActiveNotification
    //WKApplicationDidFinishLaunchingNotification
    //WKApplicationWillResignActiveNotification

    //NSExtensionHostDidBecomeActiveNotification
    //NSExtensionHostDidEnterBackgroundNotification
    //WKApplicationWillResignActiveNotification
#elif TARGET_OS_IOS || TARGET_OS_TV

    // when with UIKit:
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationInForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationInBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationTerminated)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];

//#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
#else
    // when with AppKit:
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationInForeground)
                                                 name:NSApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationInBackground)
                                                 name:NSApplicationDidResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationTerminated)
                                                 name:NSApplicationWillTerminateNotification
                                               object:nil];
#endif
}

- (void)applicationInForeground:(NSNotification *)notification {
    //TODO: implement...
}

- (void)applicationInBackground:(NSNotification *)notification {
    //TODO: implement...
}

- (void)applicationTerminated:(NSNotification *)notification {
    //TODO: implement...
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

@end
