@import RollbarCommon;

NS_ASSUME_NONNULL_BEGIN

/// Models developer settings of a configuration
@interface RollbarDeveloperOptions : RollbarDTO

#pragma mark - properties

/// Rollbar operation enabled flag
@property (nonatomic) BOOL enabled;

/// Enables/disables actual transmission of the payloads
@property (nonatomic) BOOL transmit;

/// A flag to suppress internal SDK's informational logging
@property (nonatomic) BOOL suppressSdkInfoLogging;

/// Flags if the processed payloads to be logged locally
@property (nonatomic) BOOL logPayload;

/// Log file to use for  local logged payloads
@property (nonatomic, copy) NSString *payloadLogFile;

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

NS_ASSUME_NONNULL_END
