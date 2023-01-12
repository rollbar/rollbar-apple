#import "RollbarCrashInstallation.h"
#import "RollbarCrashReportSink.h"

@implementation RollbarCrashInstallation

+ (instancetype)sharedInstance {
    static RollbarCrashInstallation *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RollbarCrashInstallation alloc] init];
    });

    return sharedInstance;
}

- (id)init {
    return [super initWithRequiredProperties:@[]];
}

- (id<KSCrashReportFilter>)sink {
    return [[[RollbarCrashReportSink alloc] init] defaultFilterSet];
}

- (void)sendAllReportsWithCompletion:(KSCrashReportFilterCompletion)onCompletion {
    [super sendAllReportsWithCompletion:^(NSArray *filteredReports, BOOL completed, NSError *error) {
        if (completed && onCompletion) {
            onCompletion(filteredReports, completed, error);
        }
    }];
}

@end
