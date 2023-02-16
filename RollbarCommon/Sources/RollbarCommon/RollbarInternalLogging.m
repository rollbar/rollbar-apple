#import "RollbarInternalLogging.h"

void RBCLog(NSString *format, ...) {
#ifdef DEBUG
    va_list args;
    va_start(args, format);
    fprintf(
        stdout, "[Rollbar] %s\n",
        [[[NSString alloc] initWithFormat:format arguments:args] UTF8String]);
    va_end(args);
#endif
}

void RBCErr(NSString *format, ...) {
#ifdef DEBUG
    va_list args;
    va_start(args, format);
    fprintf(
        stderr, "[Rollbar] %s\n",
        [[[NSString alloc] initWithFormat:format arguments:args] UTF8String]);
    va_end(args);
#endif
}
