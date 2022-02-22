#import "RollbarLog.h"
#import "RollbarTelemetry.h"

void RollbarLog(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    [RollbarTelemetry NSLogReplacement:[[NSString alloc] initWithFormat:format arguments:args]];
    va_end(args);
}
