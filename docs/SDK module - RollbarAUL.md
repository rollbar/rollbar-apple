# SDK Module: RollbarAUL

This module implements `RollbarNotifier` integration with *Apple Unified Logging (AUL)* and allows capture of the AUL entries as corresponding Rollbar Telemetry log events.

---

## Essential Components of the Module

### `RollbarAulStoreMonitorOptions` DTO

It implements configurational options for collecting relevant log entries from the Apple Unified Logging (AUL) store.
You can specify here lists of AUL subsystems and categories of interest. When these lists are empty, all the entries from the local AUL store related to the application process will be collected from the store.

### `RollbarAulStoreMonitor` Service

It implements a singleton-like component that monitors the AUL local store and retrieves relevant entries from it based on provided `RollbarAulStoreMonitorOptions` instance. These entries will be captured as Rollbar Telemetry log events. Hence, the Telemetry must be enabled as well as its capture of the log entries.
This component implements the following key protocols.

### `RollbarAulStoreMonitoring` Protocol

Allows to start and cancel the monitoring service as well as provides optional methods to configure the service with custom `RollbarAulStoreMonitorOptions` and/or a custom `RollbarLogger` instance.

### `RollbarSingleInstancing` Protocol

Defines access to the singleton of the type implementing this protocol.
Optionally, defines methods to test on the singleton instance existence and a method to define custom singleton deallocation logic.



## Examples

### Using the RollbarAulStoreMonitor to capture the application AUL entries

1. Make sure you have properly configured `RollbarConfig` instance and the Telemetry and its log capture options are both enabled.
2. Setup a `RollbarLogger` instance with that `RolbarConfig` instance.
3. Configure the `RollbarAulStoreMonitor` service with that `RollbarLogger` instance.
4. Optionally, you can create a custom-configured `RollbarAulStoreMonitorOptions` instance and configure the `RollbarAulStoreMonitor` service with it.
5. Start the `RollbarAulStoreMonitor` service.
6. Any AUL entry made from your application process will be collected by the SDK as corresponding Telemetry log events according to the provided `RollbarAulStoreMonitorOptions`...

#### Objective-C

```Obj-C
// Create proper RollbarConfig instance making sure 
// the Telemetry and its log capture are enabled:
RollbarConfig *rollbarConfig = [[RollbarConfig alloc] init];
rollbarConfig.destination.accessToken = @"<YOUR_PROJECT_ACCESS_TOKEN>";
rollbarConfig.destination.environment = @"<YOUR_ENVIRONMENT_TAG>";
rollbarConfig.developerOptions.transmit = YES;
rollbarConfig.telemetry.enabled = YES;              // required for AUL capture
rollbarConfig.telemetry.captureLog = YES;           // required for AUL capture
rollbarConfig.telemetry.maximumTelemetryData = 100;

// Setup shared RollbarLogger with the config:
[Rollbar initWithConfiguration:rollbarConfig];

// Configure the AUL monitor with the logger:
[RollbarAulStoreMonitor.sharedInstance configureRollbarLogger:Rollbar.currentLogger];

// Optionally, configure the AUL monitoring options:
RollbarAulStoreMonitorOptions *aulMonitorOptions =
[[RollbarAulStoreMonitorOptions alloc] init];
[aulMonitorOptions addAulSubsystem:@"DataAccessLayer"];
[aulMonitorOptions addAulSubsystem:@"Model"];
[aulMonitorOptions addAulCategory:@"CompanyOrg"];
[RollbarAulStoreMonitor.sharedInstance configureWithOptions:aulMonitorOptions];

// Start the AUL monitoring:
[RollbarAulStoreMonitor.sharedInstance start];
```

#### Swift

```Swift
// Create proper RollbarConfig instance making sure 
// the Telemetry and its log capture are enabled:
let config = RollbarConfig();
config.destination.accessToken = "<YOUR_PROJECT_ACCESS_TOKEN>";
config.destination.environment = "<YOUR_ENVIRONMENT_TAG>";
config.developerOptions.transmit = true;
config.telemetry.enabled = true;
config.telemetry.captureLog = true;

// Setup shared RollbarLogger with the config:
Rollbar.initWithConfiguration(config);

// Configure the AUL monitor with the logger:
RollbarAulStoreMonitor.sharedInstance().configureRollbarLogger(Rollbar.currentLogger());

// Optionally, configure the AUL monitoring options:
let aulOptions = RollbarAulStoreMonitorOptions();
aulOptions.addAulSubsystem("DataAccessLayer");
aulOptions.addAulSubsystem("Model");
aulOptions.addAulCategory("CompanyOrg");
RollbarAulStoreMonitor.sharedInstance().configure(with: aulOptions);

// Start the AUL monitoring:
RollbarAulStoreMonitor.sharedInstance().start();
```
