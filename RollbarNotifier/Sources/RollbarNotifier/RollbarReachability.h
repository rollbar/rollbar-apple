/*
 Copyright (c) 2011, Tony Million.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 */

@import Foundation;

#if !TARGET_OS_WATCH

@import SystemConfiguration;

/**
 * Does ARC support GCD objects?
 * It does if the minimum deployment target is iOS 6+ or Mac OS X 8+
 *
 * @see http://opensource.apple.com/source/libdispatch/libdispatch-228.18/os/object.h
 **/
#if OS_OBJECT_USE_OBJC
#define NEEDS_DISPATCH_RETAIN_RELEASE 0
#else
#define NEEDS_DISPATCH_RETAIN_RELEASE 1
#endif

/**
 * Create NS_ENUM macro if it does not exist on the targeted version of iOS or OS X.
 *
 * @see http://nshipster.com/ns_enum-ns_options/
 **/
#ifndef NS_ENUM
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#endif

extern NSString *const kReachabilityChangedNotification;

typedef NS_ENUM(NSInteger, NetworkStatus) {
    // Apple NetworkStatus Compatible Names.
    NotReachable     = 0,
    ReachableViaWiFi = 2,
    ReachableViaWWAN = 1
};

@class RollbarReachability;

typedef void (^NetworkReachable)(RollbarReachability *reachability);
typedef void (^NetworkUnreachable)(RollbarReachability *reachability);

/// Network reachability helper
@interface RollbarReachability : NSObject

/// Block to invoke when becomes reachable.
@property (nonatomic, copy) NetworkReachable    reachableBlock;

/// Block to invoke when becomes unreachable.
@property (nonatomic, copy) NetworkUnreachable  unreachableBlock;


/// Flags reachability via wireless/cellular connection.
@property (nonatomic, assign) BOOL reachableOnWWAN;

/// Detects reachability
/// @param hostname host name to reach
+(RollbarReachability *)reachabilityWithHostname:(NSString *)hostname;

// This is identical to the function above, but is here to maintain
//compatibility with Apples original code. (see .m)

/// Detects reachability
/// @param hostname host name to reach
+(RollbarReachability *)reachabilityWithHostName:(NSString *)hostname;

/// Detects Internet reachability
+(RollbarReachability *)reachabilityForInternetConnection;

/// Detects reachability
/// @param hostAddress host's address
+(RollbarReachability *)reachabilityWithAddress:(const struct sockaddr_in *)hostAddress;

/// Detects reachability of local WiFi
+(RollbarReachability *)reachabilityForLocalWiFi;

/// Initializer
/// @param ref reference to a SCNetworkReachability
-(RollbarReachability *)initWithReachabilityRef:(SCNetworkReachabilityRef)ref;

/// Starts the notifier
-(BOOL)startNotifier;

/// Stops the notifier
-(void)stopNotifier;

/// Flags reachability any status
-(BOOL)isReachable;

/// Flags reachability via cellular status
-(BOOL)isReachableViaWWAN;

/// Flags reachability via WiFi status
-(BOOL)isReachableViaWiFi;

/// WWAN may be available, but not active until a connection has been established.
/// WiFi may require a connection for VPN on Demand.
/// Identical DDG variant.
-(BOOL)isConnectionRequired;

/// Apple's routine.
-(BOOL)connectionRequired;

/// Dynamic, on demand connection?
-(BOOL)isConnectionOnDemand;

/// Is user intervention required?
-(BOOL)isInterventionRequired;

/// Returns current reachability status
-(NetworkStatus)currentReachabilityStatus;

/// Returns current reachability flags
-(SCNetworkReachabilityFlags)reachabilityFlags;

/// Returns current reachability status as a String
-(NSString *)currentReachabilityString;

/// Returns current reachability flags as a String
-(NSString *)currentReachabilityFlags;

@end

#endif // !TARGET_OS_WATCH
