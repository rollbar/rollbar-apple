#import "RollbarSdkLog.h"

void RollbarSdkLog(NSString *format, ...) {
#ifdef DEBUG
    va_list args;
    va_start(args, format);
    fprintf(
        stderr, "[Rollbar] %s\n",
        [[[NSString alloc] initWithFormat:format arguments:args] UTF8String]);
    va_end(args);
#endif
}
