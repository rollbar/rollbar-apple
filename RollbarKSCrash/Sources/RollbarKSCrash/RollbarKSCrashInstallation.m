#import "RollbarKSCrashInstallation.h"
#import "RollbarKSCrashReportSink.h"

@implementation RollbarKSCrashInstallation

+ (instancetype)sharedInstance {
    static RollbarKSCrashInstallation *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RollbarKSCrashInstallation alloc] init];
    });

    return sharedInstance;
}

- (id)init {
    return [super initWithRequiredProperties:@[]];
}

- (id<KSCrashReportFilter>)sink {
    return [[[RollbarKSCrashReportSink alloc] init] defaultFilterSet];
}

- (void)sendAllReportsWithCompletion:(KSCrashReportFilterCompletion)onCompletion {
    [super sendAllReportsWithCompletion:^(NSArray *filteredReports, BOOL completed, NSError *error) {
        if (completed && onCompletion) {
            onCompletion(filteredReports, completed, error);
        }
    }];
}

@end
