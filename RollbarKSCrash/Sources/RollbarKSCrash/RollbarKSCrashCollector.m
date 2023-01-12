#import "RollbarKSCrashCollector.h"
#import "RollbarCrashReportData.h"
#import "RollbarKSCrashInstallation.h"
#import "RollbarKSCrashReportSink.h"

@import RollbarNotifier;

@implementation RollbarKSCrashCollector

+ (void)initialize {
    if (self == [RollbarKSCrashCollector class]) {
        [[RollbarKSCrashInstallation sharedInstance] install];
    }
}

- (void)collectCrashReports {
    NSMutableArray<RollbarCrashReportData *> *crashReports = [[NSMutableArray alloc] init];

    [[RollbarKSCrashInstallation sharedInstance] sendAllReportsWithCompletion:^(NSArray *filteredReports, BOOL completed, NSError *error) {
        if (error) {
            RollbarSdkLog(@"Could not enable crash reporter: %@", [error localizedDescription]);
        } else if (completed) {
            for (NSString *crashReport in filteredReports) {
                RollbarCrashReportData *crashReportData = [[RollbarCrashReportData alloc] initWithCrashReport:crashReport];
                [crashReports addObject:crashReportData];
            }
        }
    }];

    self->_totalProcessedReports += crashReports.count;

    for (RollbarCrashReportData *crashRecord in crashReports) {
        [Rollbar logCrashReport:crashRecord.crashReport];

        // Let's sleep this thread for a few seconds to give the items processing thread a chance
        // to send the payload logged above so that we can handle cases when the SDK is initialized
        // right/shortly before a persistent application crash (that we have no control over) if any:
        [NSThread sleepForTimeInterval:5.0f]; // [sec]
    }
}

@end
