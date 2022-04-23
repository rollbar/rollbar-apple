//
//  RollbarOomDetectionState.m
//  
//
//  Created by Andrey Kornich on 2022-04-21.
//

#import "RollbarOomDetectionState.h"

@import SwiftUI;

@implementation RollbarOomDetectionState

#pragma mark - OS attributes detection


#pragma mark - Application attributes detection


#pragma mark - Application notification hooks

- (void)registerApplicationHooks {

#if TARGET_OS_WATCH //TARGET_OS_IPHONE

//#if TARGET_OS_WATCH
    
    // when with WatchKit:
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationInForeground)
                                                 name:WKApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationInBackground)
                                                 name:WKApplicationDidFinishLaunchingNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationTerminated)
                                                 name:WKApplicationWillResignActiveNotification
                                               object:nil];

#ifelse TARGET_OS_IPHONE //TARGET_OS_WATCH

    // when with UIKit:
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationInForeground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationInBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationTerminated)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];

//#endif
    
#else
    
    // when with AppKit:
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationInForeground)
                                                 name:NSApplicationWillBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationInBackground)
                                                 name:NSApplicationDidFinishLaunchingNotification
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
