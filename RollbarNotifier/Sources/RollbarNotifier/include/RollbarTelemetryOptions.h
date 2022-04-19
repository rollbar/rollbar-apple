@import RollbarCommon;

@class RollbarScrubbingOptions;

NS_ASSUME_NONNULL_BEGIN

/// Telemetry related settings of a configuration
@interface RollbarTelemetryOptions : RollbarDTO

#pragma mark - properties
/// Telemetry enabled flag
@property (nonatomic) BOOL enabled;

/// Capture OS log as Telemetry events flag
@property (nonatomic) BOOL captureLog;

/// Capture connectivity flag
@property (nonatomic) BOOL captureConnectivity;

/// Telemtry events buffer limit
@property (nonatomic) NSUInteger maximumTelemetryData;

/// Telemetry scrubbing options
@property (nonatomic, strong) RollbarScrubbingOptions *viewInputsScrubber;

/// Time interval for auto-collecting memtory stats
/// @note 0.0 means no collection!
@property (atomic) NSTimeInterval memoryStatsAutocollectionInterval; //[sec]

#pragma mark - initializers

/// Initializer
/// @param enabled telemetry enabled
/// @param captureLog OS log capture enabled
/// @param captureConnectivity connectivity capture enabled
/// @param viewInputsScrubber telemetry scrubbing options
- (instancetype)initWithEnabled:(BOOL)enabled
                     captureLog:(BOOL)captureLog
            captureConnectivity:(BOOL)captureConnectivity
             viewInputsScrubber:(RollbarScrubbingOptions *)viewInputsScrubber;

/// Initializer
/// @param enabled telemetry enabled
/// @param captureLog OS log capture enabled
/// @param captureConnectivity connectivity capture enabled
- (instancetype)initWithEnabled:(BOOL)enabled
                     captureLog:(BOOL)captureLog
            captureConnectivity:(BOOL)captureConnectivity;

/// Initializer
/// @param enabled telemetry enabled
- (instancetype)initWithEnabled:(BOOL)enabled;

@end

NS_ASSUME_NONNULL_END
