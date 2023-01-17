#import "RollbarInfrastructure.h"
#import "RollbarConfig.h"
#import "RollbarLoggerProtocol.h"
#import "RollbarLogger.h"
#import "RollbarNotifierFiles.h"
#import "RollbarSession.h"
#import "RollbarTelemetry.h"
#import "RollbarCrashCollector.h"

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

    self.collector = [[RollbarCrashCollector alloc] init];
    [self.collector collectCrashReports];

    [[RollbarSession sharedInstance] enableOomMonitoring:config.loggingOptions.enableOomDetection withCrashCheck:^() {
        return (BOOL)(self.collector.totalProcessedReports > 0);
    }];

    [[RollbarTelemetry sharedInstance] configureWithOptions:config.telemetry];

    RollbarSdkLog(@"%@ is configured with this RollbarConfig instance: \n%@",
                  [RollbarInfrastructure rollbar_objectClassName],
                  config);
    
    return self;
}

@end

NS_ASSUME_NONNULL_END
