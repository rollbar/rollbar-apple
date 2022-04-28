//
//  RollbarSessionState.h
//  
//
//  Created by Andrey Kornich on 2022-04-27.
//

#ifndef RollbarSessionState_h
#define RollbarSessionState_h

@import RollbarCommon;

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RollbarSessionState : RollbarDTO

@property (nonatomic, copy, nonnull) NSString *osVersion;
@property (nonatomic, copy, nonnull) NSString *appVersion;

@property (atomic, nullable) NSUUID *appID;
@property (atomic, nullable) NSUUID *sessionID;

@property (nonatomic, copy, nonnull) NSDate *sessionStartTimestamp;
@property (nonatomic, copy, nonnull) NSDate *appMemoryWarningTimestamp;
@property (nonatomic, copy, nonnull) NSDate *appTerminationTimestamp;

@property (atomic) BOOL appInBackgroundFlag;

#pragma mark - initializers

//- (instancetype)initWithAppVersion:(nulable NSString *)appVersion
//                         osVersion:(nulable NSString *)osVersion;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarSessionState_h
