#ifndef RollbarCrashReportSink_h
#define RollbarCrashReportSink_h

@import Foundation;
@import KSCrash_Reporting_Sinks;

NS_ASSUME_NONNULL_BEGIN

/// Rollbar CrashReport sink
@interface RollbarCrashReportSink : NSObject<KSCrashReportFilter>

/// Gets the default filter set
- (id<KSCrashReportFilter>)defaultFilterSet;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarCrashReportSink_h
