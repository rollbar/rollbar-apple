#import "RollbarInternalLogging.h"
#import "RollbarInfrastructure.h"

void RBLog(NSString *format, ...) {
#ifdef DEBUG
    if (RollbarInfrastructure.sharedInstance.configuration.developerOptions.suppressSdkInfoLogging) {
        return;
    }

    va_list args;
    va_start(args, format);
    fprintf(stdout, "[Rollbar] %s\n",
            [[[NSString alloc] initWithFormat:format arguments:args] UTF8String]);
    va_end(args);
#endif
}

void RBErr(NSString *format, ...) {
#ifdef DEBUG
    if (RollbarInfrastructure.sharedInstance.configuration.developerOptions.suppressSdkInfoLogging) {
        return;
    }

    va_list args;
    va_start(args, format);
    fprintf(stderr, "[Rollbar] %s\n",
            [[[NSString alloc] initWithFormat:format arguments:args] UTF8String]);
    va_end(args);
#endif
}
