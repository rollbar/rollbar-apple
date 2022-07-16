#ifndef RollbarTelemetryOptions_h
#define RollbarTelemetryOptions_h

#import "RollbarScrubbingOptions.h"

@import RollbarCommon;


NS_ASSUME_NONNULL_BEGIN

/// Telemetry related settings of a configuration
@interface RollbarTelemetryOptions : RollbarDTO

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

#pragma mark - properties
/// Telemetry enabled flag
@property (nonatomic, readonly) BOOL enabled;

/// Capture OS log as Telemetry events flag
@property (nonatomic, readonly) BOOL captureLog;

/// Capture connectivity flag
@property (nonatomic, readonly) BOOL captureConnectivity;

/// Telemtry events buffer limit
@property (nonatomic, readonly) NSUInteger maximumTelemetryData;

/// Telemetry scrubbing options
@property (nonatomic, strong, readonly) RollbarScrubbingOptions *viewInputsScrubber;

/// Time interval for auto-collecting memtory stats
/// @note 0.0 means no collection!
@property (atomic, readonly) NSTimeInterval memoryStatsAutocollectionInterval; //[sec]

@end


/// Mutable Telemetry related settings of a configuration
@interface RollbarMutableTelemetryOptions : RollbarTelemetryOptions

#pragma mark - initializers

- (instancetype)init
NS_DESIGNATED_INITIALIZER;

#pragma mark - properties
/// Telemetry enabled flag
@property (nonatomic, readwrite) BOOL enabled;

/// Capture OS log as Telemetry events flag
@property (nonatomic, readwrite) BOOL captureLog;

/// Capture connectivity flag
@property (nonatomic, readwrite) BOOL captureConnectivity;

/// Telemtry events buffer limit
@property (nonatomic, readwrite) NSUInteger maximumTelemetryData;

/// Telemetry scrubbing options   
@property (nonatomic, strong, readwrite) RollbarMutableScrubbingOptions *viewInputsScrubber;

/// Time interval for auto-collecting memtory stats
/// @note 0.0 means no collection!
@property (atomic, readwrite) NSTimeInterval memoryStatsAutocollectionInterval; //[sec]

@end

NS_ASSUME_NONNULL_END

#endif //RollbarTelemetryOptions_h
