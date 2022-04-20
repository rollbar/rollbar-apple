#ifndef RollbarConfig_h
#define RollbarConfig_h

#import "RollbarCaptureIpType.h"
#import "RollbarLevel.h"

@import RollbarCommon;

@class RollbarDestination;
@class RollbarDeveloperOptions;
@class RollbarProxy;
@class RollbarScrubbingOptions;
@class RollbarServerConfig;
@class RollbarPerson;
@class RollbarModule;
@class RollbarTelemetryOptions;
@class RollbarLoggingOptions;
@class RollbarData;

NS_ASSUME_NONNULL_BEGIN

/// Rollbar configuration structured model
@interface RollbarConfig : RollbarDTO {
    BOOL _isRootConfiguration;
}

#pragma mark - properties
/// Destination related settings
@property (nonnull, nonatomic, strong) RollbarDestination *destination;

/// Developer related settings
@property (nonnull, nonatomic, strong) RollbarDeveloperOptions *developerOptions;

/// Logging related settings
@property (nonnull, nonatomic, strong) RollbarLoggingOptions *loggingOptions;

/// HTTP proxy related settings
@property (nonnull, nonatomic, strong) RollbarProxy *httpProxy;

/// HTTPS proxy related settings
@property (nonnull, nonatomic, strong) RollbarProxy *httpsProxy;

/// Data scrubbing related settings
@property (nonnull, nonatomic, strong) RollbarScrubbingOptions *dataScrubber;

/// Server related settings
@property (nonnull, nonatomic, strong) RollbarServerConfig *server;

/// Person/user related settings
@property (nonnull, nonatomic, strong) RollbarPerson *person;

/// Notifier related settings
@property (nonnull, nonatomic, strong) RollbarModule *notifier;

/// Telemetry related settings
@property (nonnull, nonatomic, strong) RollbarTelemetryOptions *telemetry;

#pragma mark - Custom data
@property (nonatomic, strong) NSDictionary<NSString *, id> *customData;


#pragma mark - Payload Content Related

/// Decides whether or not to send provided payload data. Returns true to ignore, false to send
@property (nullable, nonatomic, copy) BOOL (^checkIgnoreRollbarData)(RollbarData *rollbarData);
/// Modifies payload data before sending
@property (nullable, nonatomic, copy) RollbarData *(^modifyRollbarData)(RollbarData *rollbarData);


#pragma mark - Convenience Methods

/// Sets person/user related information to be sent with each payload
/// @param personId person ID
/// @param username person username
/// @param email person email
- (void)setPersonId:(nonnull NSString *)personId
           username:(nullable NSString *)username
              email:(nullable NSString *)email;

/// Sets server related information to be sent with each payload
/// @param host host name
/// @param root codebase root
/// @param branch codebase branch
/// @param codeVersion code version
- (void)setServerHost:(nullable NSString *)host
                 root:(nullable NSString *)root
               branch:(nullable NSString *)branch
          codeVersion:(nullable NSString *)codeVersion;

/// Sets notifier related information to be sent with every payload
/// @note use it only if you need to override these values auto-captured by the SDK internally
/// @param name notifier name
/// @param version notifier version
- (void)setNotifierName:(nullable NSString *)name
                version:(nullable NSString *)version;


@end

NS_ASSUME_NONNULL_END

#endif // RollbarConfig_h
