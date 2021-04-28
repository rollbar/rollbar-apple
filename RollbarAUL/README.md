# RollbarAUL

This is an SDK module implements RollbarNotifier integration with Apple Unified Logging (AUL).


Main abstractions:

- RollbarAulStoreMonitor 
This component, once enabled, hits the AUL entries store on periodic basis and reads in all the available log entries since the last check that satisfy certain application identifier, category, and log level conditions. It captures these records as Telemetry log events and also reports ones that look like either crash reports, or NSErrors/NSExceptions to Rollbar as corresponding payloads.

- RollbarAulStoreMonitorOptions
This is an extension to RollbarConfig that allows to specify all the configurational attributes related to Rollbar AUL integration.


