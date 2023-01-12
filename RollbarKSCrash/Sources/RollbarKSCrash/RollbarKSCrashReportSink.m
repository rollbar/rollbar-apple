#import "RollbarKSCrashReportSink.h"

@implementation RollbarKSCrashReportSink

- (id<KSCrashReportFilter>)defaultFilterSet {
    KSCrashReportFilterAppleFmt *format = [KSCrashReportFilterAppleFmt filterWithReportStyle:KSAppleReportStyleSymbolicated];
    KSCrashReportFilterPipeline *pipeline = [KSCrashReportFilterPipeline filterWithFilters:format, self, nil];
    return pipeline;
}

- (void)filterReports:(NSArray *)reports onCompletion:(KSCrashReportFilterCompletion)onCompletion {
    for (NSString *report in reports) {
        //[Rollbar logCrashReport:report];
    }
    kscrash_callCompletion(onCompletion, reports, YES, nil);
}

@end
