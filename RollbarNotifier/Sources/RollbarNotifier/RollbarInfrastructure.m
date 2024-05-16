#import "RollbarInfrastructure.h"
#import "RollbarConfig.h"
#import "RollbarLoggerProtocol.h"
#import "RollbarLogger.h"
#import "RollbarNotifierFiles.h"
#import "RollbarTelemetry.h"
#import "RollbarCrashCollector.h"
#import "RollbarInternalLogging.h"
#import "RollbarThread.h"

NS_ASSUME_NONNULL_BEGIN

@interface RollbarInfrastructure ()
@property (readwrite, strong) id<RollbarLogger> logger;
@property (readwrite, strong) RollbarConfig *configuration;
@property (readwrite, strong) RollbarCrashCollector *collector;
@end

@implementation RollbarInfrastructure

+ (nonnull instancetype)sharedInstance {
    static id singleton;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        singleton = [RollbarInfrastructure new];
    });
    
    return singleton;
}

#pragma mark - instance methods

- (nonnull instancetype)configureWith:(nonnull RollbarConfig *)config {

    if (self.configuration &&
        self.configuration.modifyRollbarData == config.modifyRollbarData &&
        self.configuration.checkIgnoreRollbarData == config.checkIgnoreRollbarData &&
        [[self.configuration serializeToJSONString] isEqualToString:[config serializeToJSONString]]
    ) {
        return self;
    }
    
    self.configuration = [config copy];
    self.logger = [RollbarLogger loggerWithConfiguration:self.configuration];

    [[RollbarTelemetry sharedInstance] configureWithOptions:config.telemetry];

/* Wise has tooling already in place for crash reports, so we don't want to handle crashes in Rollbar. Currently there's no option to disable this from the public API of the Rollbar SDK. */

//    self.collector = [[RollbarCrashCollector alloc] init];
//    [self.collector install];
//    [self.collector sendAllReports];

    // Create RollbarThread and begin processing persisted occurrences
    if ([[RollbarThread sharedInstance] active]) {
        NSLog(@"Rollbar is running")
    }

    return self;
}

@end

NS_ASSUME_NONNULL_END
