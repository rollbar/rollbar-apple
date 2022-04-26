//
//  RollbarOomDetectionState.m
//  
//
//  Created by Andrey Kornich on 2022-04-21.
//

#import "RollbarOomDetectionState.h"

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


//@import SwiftUI;

//#if TARGET_OS_WATCH
//@import WatchKit;
//#elif TARGET_OS_TV
//#if TARGET_OS_TV
//@import TVUIKit;
//#elif TARGET_OS_IOS
//@import UIKit;
//@import TVUIKit;
//#else
//@import AppKit;
//#endif

@implementation RollbarOomDetectionState

#pragma mark - OS attributes detection


#pragma mark - Application attributes detection


#pragma mark - Application notification hooks

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
    //TODO: implement...
}

- (void)applicationInBackground:(NSNotification *)notification {
    //TODO: implement...
}

- (void)applicationTerminated:(NSNotification *)notification {
    //TODO: implement...
}

- (void)applicationReceivedMemoryWarning:(NSNotification *)notification {
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
