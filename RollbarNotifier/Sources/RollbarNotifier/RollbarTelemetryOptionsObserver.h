@import Foundation;

@class RollbarTelemetryOptions;

/// Telemetry options observer
@interface RollbarTelemetryOptionsObserver : NSObject

/// Registers with a Telemetry options object to observe its changes.
/// @param telemetryOptions the Telemetry options object.
- (void)registerAsObserverForTelemetryOptions:(RollbarTelemetryOptions *)telemetryOptions;

/// Unregisters from observing Telemetry options object changes.
/// @param telemetryOptions the Telemetry options object.
- (void)unregisterAsObserverForTelemetryOptions:(RollbarTelemetryOptions *)telemetryOptions;

/// Callback invoked when any keyed value of an observed object changes.
/// @param keyPath the key path of the change
/// @param object the observed object
/// @param change the observed change
/// @param context an extra context for the change
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context;

@end
