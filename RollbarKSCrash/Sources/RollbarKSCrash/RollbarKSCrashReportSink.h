#ifndef RollbarKSCrashReportSink_h
#define RollbarKSCrashReportSink_h

@import Foundation;
@import KSCrash_Reporting_Sinks;

NS_ASSUME_NONNULL_BEGIN

/// Rollbar KSCrashReport sink
@interface RollbarKSCrashReportSink : NSObject<KSCrashReportFilter>

/// Gets the default filter set
- (id<KSCrashReportFilter>)defaultFilterSet;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarKSCrashReportSink_h
