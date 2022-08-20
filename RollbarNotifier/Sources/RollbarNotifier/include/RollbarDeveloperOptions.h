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

/// Flags if the incoming payloads to be logged locally
@property (nonatomic, readonly) BOOL logIncomingPayloads;

/// Flags if the transmitted payloads to be logged locally
@property (nonatomic, readonly) BOOL logTransmittedPayloads;

/// Flags if the dropped payloads to be logged locally
@property (nonatomic, readonly) BOOL logDroppedPayloads;

/// Log file to use for  local logged incoming payloads
@property (nonatomic, readonly, copy) NSString *incomingPayloadLogFile;

/// Log file to use for  local logged transmitted payloads
@property (nonatomic, readonly, copy) NSString *transmittedPayloadLogFile;

/// Log file to use for  local logged dropped payloads
@property (nonatomic, readonly, copy) NSString *droppedPayloadLogFile;

#pragma mark - initializers

/// Initializer
/// @param enabled enabled flag
/// @param transmit payloads transmission flag
/// @param logIncomingPayloads flag to log incoming payloads locally
/// @param logTransmittedPayloads flag to log transmitted payloads locally
/// @param logDroppedPayloads flag to log dropped payloads locally
/// @param logIncomingPayloadsFile file to log incoming payloads to
/// @param logTransmittedPayloadsFile file to log transmitted payloads to
/// @param logDroppedPayloadsFile file to log dropped payloads to
- (instancetype)initWithEnabled:(BOOL)enabled
                       transmit:(BOOL)transmit
            logIncomingPayloads:(BOOL)logIncomingPayloads
         logTransmittedPayloads:(BOOL)logTransmittedPayloads
             logDroppedPayloads:(BOOL)logDroppedPayloads
        incomingPayloadsLogFile:(NSString *)logIncomingPayloadsFile
     transmittedPayloadsLogFile:(NSString *)logTransmittedPayloadsFile
         droppedPayloadsLogFile:(NSString *)logDroppedPayloadsFile;

/// Initializer
/// @param enabled enabled flag
/// @param transmit payloads transmission flag
/// @param logIncomingPayloads flag to log incoming payloads locally
/// @param logTransmittedPayloads flag to log transmitted payloads locally
/// @param logDroppedPayloads flag to log dropped payloads locally
- (instancetype)initWithEnabled:(BOOL)enabled
                       transmit:(BOOL)transmit
            logIncomingPayloads:(BOOL)logIncomingPayloads
         logTransmittedPayloads:(BOOL)logTransmittedPayloads
             logDroppedPayloads:(BOOL)logDroppedPayloads;

/// Initializer
/// @param enabled flag enabling/suspending the SDK operation
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

/// Flags if the incoming payloads to be logged locally
@property (nonatomic, readwrite) BOOL logIncomingPayloads;

/// Flags if the transmitted payloads to be logged locally
@property (nonatomic, readwrite) BOOL logTransmittedPayloads;

/// Flags if the dropped payloads to be logged locally
@property (nonatomic, readwrite) BOOL logDroppedPayloads;

/// Log file to use for  local logged incoming payloads
@property (nonatomic, readwrite, copy) NSString *incomingPayloadLogFile;

/// Log file to use for  local logged transmitted payloads
@property (nonatomic, readwrite, copy) NSString *transmittedPayloadLogFile;

/// Log file to use for  local logged dropped payloads
@property (nonatomic, readwrite, copy) NSString *droppedPayloadLogFile;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarDeveloperOptions_h
