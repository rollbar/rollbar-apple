#ifndef RollbarDeveloperOptions_h
#define RollbarDeveloperOptions_h

@import RollbarCommon;

NS_ASSUME_NONNULL_BEGIN

/// Models developer settings of a configuration
@interface RollbarDeveloperOptions : RollbarDTO

#pragma mark - properties

/// Rollbar operation enabled flag
@property (nonatomic, readonly) BOOL enabled;

/// Enables/disables actual transmission of the payloads
@property (nonatomic, readonly) BOOL transmit;

/// A flag to suppress internal SDK's informational logging
@property (nonatomic, readonly) BOOL suppressSdkInfoLogging;

/// Flags if the processed payloads to be logged locally
@property (nonatomic, readonly) BOOL logPayload;

/// Log file to use for  local logged payloads
@property (nonatomic, readonly, copy) NSString *payloadLogFile;

#pragma mark - initializers

/// Initializer
/// @param enabled enabled flag
/// @param transmit payloads transmission flag
/// @param logPayload local payloads logging flag
/// @param logPayloadFile pocal payloads logging file
- (instancetype)initWithEnabled:(BOOL)enabled
                       transmit:(BOOL)transmit
                     logPayload:(BOOL)logPayload
                 payloadLogFile:(NSString *)logPayloadFile;

/// Initializer
/// @param enabled enabled flag
/// @param transmit payloads transmission flag
/// @param logPayload local payloads logging flag
- (instancetype)initWithEnabled:(BOOL)enabled
                       transmit:(BOOL)transmit
                     logPayload:(BOOL)logPayload;
- (instancetype)initWithEnabled:(BOOL)enabled;

@end

@interface RollbarMutableDeveloperOptions : RollbarDeveloperOptions

#pragma mark - properties

/// Rollbar operation enabled flag
@property (nonatomic, readwrite) BOOL enabled;

/// Enables/disables actual transmission of the payloads
@property (nonatomic, readwrite) BOOL transmit;

/// A flag to suppress internal SDK's informational logging
@property (nonatomic, readwrite) BOOL suppressSdkInfoLogging;

/// Flags if the processed payloads to be logged locally
@property (nonatomic, readwrite) BOOL logPayload;

/// Log file to use for  local logged payloads
@property (nonatomic, readwrite, copy) NSString *payloadLogFile;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarDeveloperOptions_h
