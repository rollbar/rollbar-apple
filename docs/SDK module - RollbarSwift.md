# SDK Module: RollbarSwift

This module implements components useful in cases when the SDK is used by a client code written in Swift. For example, any call chain made from Swift that eventually resolves into an Objective-C code being invoked can potentially produce an NSException that Swift cannot handle natively. So, the RollbarSwift module provides utility classes and components that are helping to either handle or process such scenarios.

---

## Essential Components of the Module

### `RollbarTryCatch`

This utility class provides an API to try Swift code blocks and to catch and to either handle or process any of `NSException` instances if thrown from the tried block.

### `RollbarExceptionGuard`

This component is meant to be initialized with a preconfigured instance of `RollbarLogger` so it can be used to try/guard a block of Swift code in cases when it might cause throwing of an `NSException` and to automatically report such `NSException` (if any) to a Rollbar.com Project. It also provides an alternative method that in addition converts the intercepted `NSException` into a matching `NSError` that could be natively tied and handled from within the Swift code.

## Examples

### Guarding Swift code that could potentially throw a NSException and reporting the exception (if any) to Rollbar

```Swift
func generateObjCException() {
  
    //simulating Obj-C NSException:
    RollbarTryCatch.throw("NSException from Obj-C...");
}

func handleObjCExceptionWithRollbar() {
      
    let exceptionGuard = createGuard();
    var success = true;
    //execute code block while guarding it with RollbarExceptionGuard:
    success = exceptionGuard.tryExecute {
        self.generateObjCException();
    }
    //if there was an NSException thrown withing the guarded block of code,
    //the guard instance would return NO and internally report the
    //exception details to Rollbar.
    
    print("Guarded execution succeeded: \(success).");
}
  
func createGuard() -> RollbarExceptionGuard {
  
    let config = RollbarConfig();
    config.destination.accessToken = "2ff...0f3";
    config.destination.environment = "samples";
    config.developerOptions.transmit = true;

    let logger = RollbarLogger(configuration: config);

    let exceptionGuard = RollbarExceptionGuard(logger: logger);

    return exceptionGuard;
}
```
