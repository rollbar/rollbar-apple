//  Copyright © 2018 Rollbar. All rights reserved.

#ifndef RollbarDeployment_h
#define RollbarDeployment_h

@import Foundation;
@import RollbarCommon;

/// Models a Deployment
@interface RollbarDeployment : RollbarDTO

#pragma mark - properties

/// Rollbar project environment
@property (readonly, retain) NSString *environment;

/// Comment
@property (readonly, retain) NSString *comment;

/// Revision ID
@property (readonly, retain) NSString *revision;

/// Local user's name
@property (readonly, retain) NSString *localUsername;

/// Rollbar user's name
@property (readonly, retain) NSString *rollbarUsername;

#pragma mark - initializers

/// Designated initializer
/// @param environment Rollbar project environment
/// @param comment Comment
/// @param revision Revision ID
/// @param localUserName local user's name
/// @param rollbarUserName Rollbar user's name
- (instancetype)initWithEnvironment:(NSString *)environment
                            comment:(NSString *)comment
                           revision:(NSString *)revision
                      localUserName:(NSString *)localUserName
                    rollbarUserName:(NSString *)rollbarUserName
NS_DESIGNATED_INITIALIZER;

/// Designated initializer
/// @param data data dictionary with initial property values
- (instancetype)initWithDictionary:(NSDictionary<NSString *, id> *)data
NS_DESIGNATED_INITIALIZER;

/// Hides this initializer.
/// @param data valid JSON NSArray seed
- (instancetype)initWithArray:(NSArray *)data
NS_UNAVAILABLE;

/// Hides this initializer.
- (instancetype)init
NS_UNAVAILABLE;

@end

#endif //RollbarDeployment_h
