#ifndef Rollbar_h
#define Rollbar_h

@import Foundation;

#import "RollbarInfrastructure.h"
#import "RollbarLevel.h"
#import "RollbarTelemetry.h"
#import "RollbarTelemetryType.h"

@class RollbarConfig;
@class RollbarLogger;
@protocol RollbarCrashCollector;

// Macros that help in throwing an exception with its source location metadata included:
#define __ThrowException(name, reason, class, function, file, line, info) [NSException exceptionWithName:name reason:[NSString stringWithFormat:@"%s:%i (%@:%s) %@", file, line, class, function, reason]  userInfo:info];
#define ThrowException(name, reason, info) __ThrowException(name, reason, [self class], _cmd, __FILE__, __LINE__, info)

/// Globa;l uncaught exception handler that sends provided exception data to Rollbar via preconfigured RollbarInfrastructure's shared instnace.
/// @param exception an exception to report to Rolbar
// Add a call to the: NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
// to the end of your: -(BOOL)application:didFinishLaunchingWithOptions: method in AppDelegate.
// Make sure that the [RollbarInfrastructure sharedInstance] was already configured as early as possible within the:
// -(BOOL)application:didFinishLaunchingWithOptions: method in AppDelegate.
static void uncaughtExceptionHandler(NSException * _Nonnull exception);

@interface Rollbar : NSObject

#pragma mark - Class Initializers

/// Class initializer.
/// @param accessToken Rollbar project access token
+ (void)initWithAccessToken:(nonnull NSString *)accessToken;

/// Class initializer.
/// @param configuration a Rollbar configuration
+ (void)initWithConfiguration:(nonnull RollbarConfig *)configuration;

/// Class initializer.
/// @param accessToken a Rollbar project access token
/// @param crashCollector a crash collector
+ (void)initWithAccessToken:(nonnull NSString *)accessToken
             crashCollector:(nullable id<RollbarCrashCollector>)crashCollector;

/// Class initializer.
/// @param configuration a Rollbar configuration
/// @param crashCollector a crash collector
+ (void)initWithConfiguration:(nonnull RollbarConfig *)configuration
               crashCollector:(nullable id<RollbarCrashCollector>)crashCollector;

#pragma mark - Configuration

/// The shared Rollbar master configuration.
+ (nonnull RollbarConfig *)configuration;

/// Updates with a shared configuration.
/// @param configuration a new Rollbar configuration
+ (void)updateConfiguration:(nonnull RollbarConfig *)configuration;


// TODO: remove this method...
//+ (nullable RollbarMutableConfig *)currentConfiguration;


// TODO: remove this method...
//+ (void)reapplyConfiguration;

#pragma mark - Shared/global notifier

// TODO: remove this method...
//+ (nonnull RollbarLogger *)currentLogger;




#pragma mark - Logging methods

/// Logs a crash report
/// @param crashReport a crash report
+ (void)logCrashReport:(nonnull NSString *)crashReport;

/// Logs a message
/// @param level a Rollbar log level
/// @param message a message to log
+ (void)log:(RollbarLevel)level
    message:(nonnull NSString *)message;

/// Logs an exception
/// @param level a Rollbar log level
/// @param exception an exception to log
+ (void)log:(RollbarLevel)level
  exception:(nonnull NSException *)exception;

/// Logs an error
/// @param level a Rollbar level
/// @param error an error to log
+ (void)log:(RollbarLevel)level
      error:(nonnull NSError *)error;

/// Logs a message
/// @param level a Rollbar log level
/// @param message a message to log
/// @param data an extra data
+ (void)log:(RollbarLevel)level
    message:(nonnull NSString *)message
       data:(nullable NSDictionary<NSString *, id> *)data;

/// Logs an exception
/// @param level a Rollbar log level
/// @param exception an exception
/// @param data an extra data
+ (void)log:(RollbarLevel)level
  exception:(nonnull NSException *)exception
       data:(nullable NSDictionary<NSString *, id> *)data;

/// Logs an error
/// @param level a Rollbar log level
/// @param error an error
/// @param data an extra data
+ (void)log:(RollbarLevel)level
      error:(nonnull NSError *)error
       data:(nullable NSDictionary<NSString *, id> *)data;

/// Logs a message
/// @param level a Rollbar log level
/// @param message a message
/// @param data an extra data
/// @param context an extra context
+ (void)log:(RollbarLevel)level
    message:(nonnull NSString *)message
       data:(nullable NSDictionary<NSString *, id> *)data
    context:(nullable NSString *)context;

/// Logs an exception
/// @param level a Rollbar log level
/// @param exception an exception
/// @param data an extra data
/// @param context an extra context
+ (void)log:(RollbarLevel)level
  exception:(nonnull NSException *)exception
       data:(nullable NSDictionary<NSString *, id> *)data
    context:(nullable NSString *)context;

/// Logs an error
/// @param level a Rollbar log level
/// @param error an error
/// @param data an extra data
/// @param context an extra context
+ (void)log:(RollbarLevel)level
      error:(nonnull NSError *)error
       data:(nullable NSDictionary<NSString *, id> *)data
    context:(nullable NSString *)context;

#pragma mark - Convenience logging methods

/// Performs debug level logging
/// @param message a message
+ (void)debugMessage:(nonnull NSString *)message;

/// Performs debug level logging
/// @param exception an exception
+ (void)debugException:(nonnull NSException *)exception;

/// Performs debug level logging
/// @param error an error
+ (void)debugError:(nonnull NSError *)error;

/// Performs debug level logging
/// @param message a message
/// @param data an extra data
+ (void)debugMessage:(nonnull NSString *)message
                data:(nullable NSDictionary<NSString *, id> *)data;

/// Performs debug level logging
/// @param exception an exception
/// @param data an extra data
+ (void)debugException:(nonnull NSException *)exception
                  data:(nullable NSDictionary<NSString *, id> *)data;

/// Performs debug level logging
/// @param error an error
/// @param data an extra data
+ (void)debugError:(nonnull NSError *)error
              data:(nullable NSDictionary<NSString *, id> *)data;

/// Performs debug level logging
/// @param message a message
/// @param data an extra data
/// @param context an extra context
+ (void)debugMessage:(nonnull NSString *)message
                data:(nullable NSDictionary<NSString *, id> *)data
             context:(nullable NSString *)context;

/// Performs debug level logging
/// @param exception an exception
/// @param data an extra data
/// @param context an extra context
+ (void)debugException:(nonnull NSException *)exception
                  data:(nullable NSDictionary<NSString *, id> *)data
               context:(nullable NSString *)context;

/// Performs debug level logging
/// @param error an error
/// @param data an extra data
/// @param context an extra context
+ (void)debugError:(nonnull NSError *)error
              data:(nullable NSDictionary<NSString *, id> *)data
           context:(nullable NSString *)context;


/// Performs info level logging
/// @param message a message
+ (void)infoMessage:(nonnull NSString *)message;

/// Performs info level logging
/// @param exception an exception
+ (void)infoException:(nonnull NSException *)exception;

/// Performs info level logging
/// @param error an error
+ (void)infoError:(nonnull NSError *)error;

/// Performs info level logging
/// @param message a message
/// @param data an extra data
+ (void)infoMessage:(nonnull NSString *)message
               data:(nullable NSDictionary<NSString *, id> *)data;

/// Performs info level logging
/// @param exception an exception
/// @param data an extra data
+ (void)infoException:(nonnull NSException *)exception
                 data:(nullable NSDictionary<NSString *, id> *)data;

/// Performs info level logging
/// @param error an error
/// @param data an extra data
+ (void)infoError:(nonnull NSError *)error
             data:(nullable NSDictionary<NSString *, id> *)data;

/// Performs info level logging
/// @param message a message
/// @param data an extra data
/// @param context an extra context
+ (void)infoMessage:(nonnull NSString *)message
               data:(nullable NSDictionary<NSString *, id> *)data
            context:(nullable NSString *)context;

/// Performs info level logging
/// @param exception an exception
/// @param data an extra data
/// @param context an extra context
+ (void)infoException:(nonnull NSException *)exception
                 data:(nullable NSDictionary<NSString *, id> *)data
              context:(nullable NSString *)context;

/// Performs info level logging
/// @param error an error
/// @param data an extra data
/// @param context an extra context
+ (void)infoError:(nonnull NSError *)error
             data:(nullable NSDictionary<NSString *, id> *)data
          context:(nullable NSString *)context;

/// Performs warning level logging
/// @param message a message
+ (void)warningMessage:(nonnull NSString *)message;

/// Performs warning level logging
/// @param exception an exception
+ (void)warningException:(nonnull NSException *)exception;

/// Performs warning level logging
/// @param error an error
+ (void)warningError:(nonnull NSError *)error;

/// Performs warning level logging
/// @param message a message
/// @param data an extra data
+ (void)warningMessage:(nonnull NSString *)message
                  data:(nullable NSDictionary<NSString *, id> *)data;

/// Performs warning level logging
/// @param exception an exception
/// @param data an extra data
+ (void)warningException:(nonnull NSException *)exception
                    data:(nullable NSDictionary<NSString *, id> *)data;

/// Performs warning level logging
/// @param error an error
/// @param data an extra data
+ (void)warningError:(nonnull NSError *)error
                data:(nullable NSDictionary<NSString *, id> *)data;

/// Performs warning level logging
/// @param message a message
/// @param data an extra data
/// @param context an extra context
+ (void)warningMessage:(nonnull NSString *)message
                  data:(nullable NSDictionary<NSString *, id> *)data
               context:(nullable NSString *)context;

/// Performs warning level logging
/// @param exception an exception
/// @param data an extra data
/// @param context an extra context
+ (void)warningException:(nonnull NSException *)exception
                    data:(nullable NSDictionary<NSString *, id> *)data
                 context:(nullable NSString *)context;

/// Performs warning level logging
/// @param error an error
/// @param data an extra data
/// @param context an extra context
+ (void)warningError:(nonnull NSError *)error
                data:(nullable NSDictionary<NSString *, id> *)data
             context:(nullable NSString *)context;

/// Performs error level logging
/// @param message a message
+ (void)errorMessage:(nonnull NSString *)message;

/// Performs error level logging
/// @param exception an exception
+ (void)errorException:(nonnull NSException *)exception;

/// Performs error level logging
/// @param error an error
+ (void)errorError:(nonnull NSError *)error;

/// Performs error level logging
/// @param message a message
/// @param data an extra data
+ (void)errorMessage:(nonnull NSString *)message
                data:(nullable NSDictionary<NSString *, id> *)data;

/// Performs error level logging
/// @param exception an exception
/// @param data an extra data
+ (void)errorException:(nonnull NSException *)exception
                  data:(nullable NSDictionary<NSString *, id> *)data;

/// Performs error level logging
/// @param error an error
/// @param data an extra data
+ (void)errorError:(nonnull NSError *)error
              data:(nullable NSDictionary<NSString *, id> *)data;

/// Performs error level logging
/// @param message a message
/// @param data an extra data
/// @param context an extra context
+ (void)errorMessage:(nonnull NSString *)message
                data:(nullable NSDictionary<NSString *, id> *)data
             context:(nullable NSString *)context;

/// Performs error level logging
/// @param exception an exception
/// @param data an extra data
/// @param context an extra context
+ (void)errorException:(nonnull NSException *)exception
                  data:(nullable NSDictionary<NSString *, id> *)data
               context:(nullable NSString *)context;

/// Performs error level logging
/// @param error an error
/// @param data an extra data
/// @param context an extra context
+ (void)errorError:(nonnull NSError *)error
              data:(nullable NSDictionary<NSString *, id> *)data
           context:(nullable NSString *)context;

/// Performs critical level logging
/// @param message a message
+ (void)criticalMessage:(nonnull NSString *)message;

/// Performs critical level logging
/// @param exception an exception
+ (void)criticalException:(nonnull NSException *)exception;

/// Performs critical level logging
/// @param error an error
+ (void)criticalError:(nonnull NSError *)error;

/// Performs critical level logging
/// @param message a message
/// @param data an extra data
+ (void)criticalMessage:(nonnull NSString *)message
                   data:(nullable NSDictionary<NSString *, id> *)data;

/// Performs critical level logging
/// @param exception an exception
/// @param data an extra data
+ (void)criticalException:(nonnull NSException *)exception
                     data:(nullable NSDictionary<NSString *, id> *)data;

/// Performs critical level logging
/// @param error an error
/// @param data an extra data
+ (void)criticalError:(nonnull NSError *)error
                 data:(nullable NSDictionary<NSString *, id> *)data;

/// Performs critical level logging
/// @param message a message
/// @param data an extra data
/// @param context an extra context
+ (void)criticalMessage:(nonnull NSString *)message
                   data:(nullable NSDictionary<NSString *, id> *)data
                context:(nullable NSString *)context;

/// Performs critical level logging
/// @param exception an exception
/// @param data an extra data
/// @param context an extra context
+ (void)criticalException:(nonnull NSException *)exception
                     data:(nullable NSDictionary<NSString *, id> *)data
                  context:(nullable NSString *)context;

/// Performs critical level logging
/// @param error an error
/// @param data an extra data
/// @param context an extra context
+ (void)criticalError:(nonnull NSError *)error
                 data:(nullable NSDictionary<NSString *, id> *)data
              context:(nullable NSString *)context;


#pragma mark - Send manually constructed JSON payload

/// Posts a Json payload
/// @param payload a Json payload
+ (void)sendJsonPayload:(nonnull NSData *)payload;

#pragma mark - Telemetry API

/// Captures a view telemetry event
/// @param level Rollbar log level
/// @param element a view element
+ (void)recordViewEventForLevel:(RollbarLevel)level
                        element:(nonnull NSString *)element;

/// Captures a view telemetry event
/// @param level Rollbar log level
/// @param element a view element
/// @param extraData an extra data
+ (void)recordViewEventForLevel:(RollbarLevel)level
                        element:(nonnull NSString *)element
                      extraData:(nullable NSDictionary<NSString *, id> *)extraData;

/// Captures a network telemetry event
/// @param level Rollbar log level
/// @param method an HTTP method
/// @param url a URL
/// @param statusCode a status code
+ (void)recordNetworkEventForLevel:(RollbarLevel)level
                            method:(nullable NSString *)method
                               url:(nullable NSString *)url
                        statusCode:(nullable NSString *)statusCode;

/// Captures a network telemetry event
/// @param level Rollbar log level
/// @param method an HTTP method
/// @param url a URL
/// @param statusCode a status code
/// @param extraData and extra data
+ (void)recordNetworkEventForLevel:(RollbarLevel)level
                            method:(nullable NSString *)method
                               url:(nullable NSString *)url
                        statusCode:(nullable NSString *)statusCode
                         extraData:(nullable NSDictionary<NSString *, id> *)extraData;

/// Captures a connectivity telemetry event
/// @param level Rollbar log level
/// @param status a connectivity status
+ (void)recordConnectivityEventForLevel:(RollbarLevel)level
                                 status:(nonnull NSString *)status;

/// Captures a connectivity telemetry event
/// @param level Rollbar log level
/// @param status a connectivity status
/// @param extraData an extra data
+ (void)recordConnectivityEventForLevel:(RollbarLevel)level
                                 status:(nonnull NSString *)status
                              extraData:(nullable NSDictionary<NSString *, id> *)extraData;

/// Captures a error telemetry event
/// @param level Rollbar log level
/// @param message a message
+ (void)recordErrorEventForLevel:(RollbarLevel)level
                         message:(nonnull NSString *)message;

/// Captures a error telemetry event
/// @param level Rollbar log level
/// @param exception an exception
+ (void)recordErrorEventForLevel:(RollbarLevel)level
                       exception:(nonnull NSException *)exception;

/// Captures a error telemetry event
/// @param level Rollbar log level
/// @param message a message
/// @param extraData an extra data
+ (void)recordErrorEventForLevel:(RollbarLevel)level
                         message:(nonnull NSString *)message
                       extraData:(nullable NSDictionary<NSString *, id> *)extraData;

/// Captures a navigation telemetry event
/// @param level Rollbar log level
/// @param from  from point
/// @param to to point
+ (void)recordNavigationEventForLevel:(RollbarLevel)level
                                 from:(nonnull NSString *)from
                                   to:(nonnull NSString *)to;

/// Captures a navigation telemetry event
/// @param level Rollbar log level
/// @param from  from point
/// @param to to point
/// @param extraData an extra data
+ (void)recordNavigationEventForLevel:(RollbarLevel)level
                                 from:(nonnull NSString *)from
                                   to:(nonnull NSString *)to
                            extraData:(nullable NSDictionary<NSString *, id> *)extraData;

/// Captures a manual telemetry event
/// @param level Rollbar log level
/// @param extraData an extra data
+ (void)recordManualEventForLevel:(RollbarLevel)level
                         withData:(nullable NSDictionary<NSString *, id> *)extraData;

@end

#endif //Rollbar_h
