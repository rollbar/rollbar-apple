#import "RollbarKSCrashCollector.h"
#import "RollbarCrashReportData.h"
#import "RollbarKSCrashInstallation.h"
#import "RollbarKSCrashReportSink.h"

@implementation RollbarKSCrashCollector

+ (void)initialize {
    if (self == [RollbarKSCrashCollector class]) {
        [[RollbarKSCrashInstallation sharedInstance] install];
    }
}

- (void)collectCrashReportsWithObserver:(NSObject<RollbarCrashCollectorObserver> *)observer {
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

    [observer onCrashReportsCollectionCompletion:crashReports];
}

@end
