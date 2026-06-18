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
@property (readwrite, strong, nullable) RollbarCrashCollector *collector;
@property (readwrite, assign) BOOL isCrashReportingEnabled;
@end

@implementation RollbarInfrastructure

+ (nonnull instancetype)sharedInstance {
    static id singleton;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        singleton = [RollbarInfrastructure new];
        [singleton setIsCrashReportingEnabled:YES];
    });
    
    return singleton;
}

#pragma mark - instance methods

- (nonnull instancetype)configureWith:(nonnull RollbarConfig *)config {

    return [self configureWith:config
       isCrashReportingEnabled:self.isCrashReportingEnabled];
}

- (nonnull instancetype)configureWith:(nonnull RollbarConfig *)config
              isCrashReportingEnabled:(BOOL)isCrashReportingEnabled {

    if (self.configuration &&
        self.isCrashReportingEnabled == isCrashReportingEnabled &&
        self.configuration.modifyRollbarData == config.modifyRollbarData &&
        self.configuration.checkIgnoreRollbarData == config.checkIgnoreRollbarData &&
        [[self.configuration serializeToJSONString] isEqualToString:[config serializeToJSONString]]
    ) {
        return self;
    }
    
    self.isCrashReportingEnabled = isCrashReportingEnabled;
    self.configuration = [config copy];
    self.logger = [RollbarLogger loggerWithConfiguration:self.configuration];

    [[RollbarTelemetry sharedInstance] configureWithOptions:config.telemetry];

    if (isCrashReportingEnabled) {
        self.collector = [[RollbarCrashCollector alloc] init];
        [self.collector install];
        [self.collector sendAllReports];
    } else {
        self.collector = nil;
    }

    // Create RollbarThread and begin processing persisted occurrences
    if ([[RollbarThread sharedInstance] active]) {
        NSLog(@"Rollbar is running")
    }

    return self;
}

@end

NS_ASSUME_NONNULL_END
