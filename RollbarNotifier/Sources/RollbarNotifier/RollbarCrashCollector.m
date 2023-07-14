@import Darwin.sys.sysctl;

#import "Rollbar.h"
#import "RollbarCrashCollector.h"
#import "RollbarInternalLogging.h"

@import RollbarReport;

static bool isDebuggerAttached() {
    static bool attached = false;

    static dispatch_once_t token;
    dispatch_once(&token, ^{
        struct kinfo_proc info;
        size_t info_size = sizeof(info);
        int name[4] = { CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid() };

        if (sysctl(name, 4, &info, &info_size, NULL, 0) == -1) {
            RBErr(@"Error checking for debugger via sysctl(): %s", strerror(errno));
        } else if (info.kp_proc.p_flag & P_TRACED) {
            RBErr(@"Found a debugger attached");
            attached = true;
        }
    });

    return attached;
}

#pragma mark -

NS_ASSUME_NONNULL_BEGIN

@interface RollbarCrashLoggingFilter : NSObject <RollbarCrashReportFilter>
@end

@implementation RollbarCrashLoggingFilter

- (void)filterReports:(NSArray *)reports
         onCompletion:(RollbarCrashReportFilterCompletion)completion
{
    for (NSString *report in reports) {
        [Rollbar logCrashReport:report];
    }

    rc_callCompletion(completion, reports, YES, nil);
}

@end

#pragma mark -

@implementation RollbarCrashCollector

- (instancetype)init {
    return [super initWithRequiredProperties:@[]];
}

- (void)install {
    [super install];

    RollbarCrashMonitorType monitoring = isDebuggerAttached()
        ? RollbarCrashMonitorTypeDebuggerSafe
        & ~(RollbarCrashMonitorTypeOptional
            | RollbarCrashMonitorTypeExperimental
            | RollbarCrashMonitorTypeUserReported)
        : RollbarCrashMonitorTypeProductionSafe
        & ~(RollbarCrashMonitorTypeOptional
            | RollbarCrashMonitorTypeUserReported);

    [RollbarCrash.sharedInstance setDeleteBehaviorAfterSendAll:RollbarCrashDeleteOnSucess];
    [RollbarCrash.sharedInstance setMonitoring:monitoring];
    [RollbarCrash.sharedInstance setAddConsoleLogToReport:NO];
    [RollbarCrash.sharedInstance setCatchZombies:NO];
    [RollbarCrash.sharedInstance setIntrospectMemory:YES];
    [RollbarCrash.sharedInstance setSearchQueueNames:NO];
}

- (void)sendAllReports {
    [self sendAllReportsWithCompletion:^(NSArray *_, BOOL completed, NSError *error) {
        if (error || !completed) {
            RBLog(@"Error reporting crash: %@", error);
        }
    }];
}

- (id<RollbarCrashReportFilter>)sink {
    id diagnose = [[RollbarCrashDiagnosticFilter alloc] init];
    id format = [[RollbarCrashFormattingFilter alloc] init];
    id log = [[RollbarCrashLoggingFilter alloc] init];
    return [RollbarCrashReportFilterPipeline filterWithFilters:diagnose, format, log, nil];
}

@end

NS_ASSUME_NONNULL_END
