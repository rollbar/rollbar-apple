# SDK Module: RollbarCocoaLumberjack

This SDK module implements integration of Rollbar into the popular CocoaLumberjack logging framework.

So if you either already use CocoaLumberjack or you are planning to use it for your software product logging needs, then you can easily integrate Rollbar into it via this module and have all or some of the logs performed via the *CocoaLumberjack* framework redirected into a dedicated Rollbar project at www.rollbar.com and monitor the health of your software product/service remotely.

---

## Essential Components of the Module

### `RollbarCocoaLumberjackLogger`

Implements CocoaLumberjack compatible logger (`DDLogger`) capable of "intercepting" log events going through the CocoaLumberjack infrastructure, converting them to Rollbar compatible payloads, and sending the payloads to a Rollbar.com Project.

## Examples

### Integrating Rollbar-Apple into existing CocoaLumberjack use case 

1. Identify place(s) in the code where you already define currently used CocoaLumberjack loggers. That is where you would want to also add a `RollbarCocoaLumberjackLogger` instance.
2. Accordingly, import our *RollbarCocoaLumberjack* module.
3. Setup properly configured `RollbarConfig` object.
4. Create a `RollbarCocoaLumberjackLogger` instance using the preconfigured `RollbarConfig` instance and add it to the `DDLog`
5. Fro this point on, all relevant log entries made anywhere via the *CocoaLumberjack* logging methods will be "forked" to Rollbar based on filtering conditions specified on both levels: *CocoaLumberjackLogger* configuration and in `RollbarConfig` instances defined above.

#### Objective-C

```Obj-C
//...
@import RollbarCocoaLumberjack;
//...

//...
    RollbarConfig *config = [[RollbarConfig alloc] init];
    config.destination.accessToken = @"ROLLBAR_ACCESS_TOKEN";
    config.destination.environment = @"ROLLBAR_ENVIRONMENT";
    config.developerOptions.transmit = YES;
    config.developerOptions.logPayload = YES;
    config.loggingOptions.maximumReportsPerMinute = 5000;

    [DDLog addLogger:[RollbarCocoaLumberjackLogger createWithRollbarConfig:config]];
//...
```

#### Swift

```Swift

```
