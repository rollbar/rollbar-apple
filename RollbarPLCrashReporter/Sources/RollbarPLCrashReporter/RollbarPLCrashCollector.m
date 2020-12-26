//
//  RollbarPLCrashCollector.m
//  
//
//  Created by Andrey Kornich on 2020-12-21.
//
@import CrashReporter;

#import "RollbarPLCrashCollector.h"
#import "RollbarCrashReportData.h"
//#import "RollbarKSCrashInstallation.h"
//#import "RollbarKSCrashReportSink.h"

@implementation RollbarPLCrashCollector

+(void)initialize {
    
    if (self == [RollbarPLCrashCollector class]) {
        //RollbarKSCrashInstallation *installation = [RollbarKSCrashInstallation sharedInstance];
        //[installation install];
    }
}

-(void)collectCrashReportsWithObserver:(NSObject<RollbarCrashCollectorObserver> *)observer {
    
    // Configure our reporter:
    PLCrashReporterSignalHandlerType signalHandlerType =
#if !TARGET_OS_TV
        PLCrashReporterSignalHandlerTypeMach;
#else
        PLCrashReporterSignalHandlerTypeBSD;
#endif
    
    PLCrashReporterConfig *config =
    [[PLCrashReporterConfig alloc] initWithSignalHandlerType: signalHandlerType
                                       symbolicationStrategy: PLCrashReporterSymbolicationStrategyAll
    ];
    PLCrashReporter *reporter =
    [[PLCrashReporter alloc] initWithConfiguration: config];

    
    if (!reporter || ![reporter hasPendingCrashReport]) {
        return;
    }

    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    
    NSArray *paths =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    if (![fm createDirectoryAtPath: documentsDirectory
       withIntermediateDirectories: YES
                        attributes:nil
                             error: &error]) {
        NSLog(@"Could not create documents directory: %@", error);
        return;
    }

    NSData *data =
    [reporter loadPendingCrashReportDataAndReturnError: &error];
    if (data == nil) {
        NSLog(@"Failed to load crash report data: %@", error);
        return;
    }
    [reporter purgePendingCrashReport];

    PLCrashReport *report =
    [[PLCrashReport alloc] initWithData: data
                                  error: &error];
    if (report == nil) {
       NSLog(@"Failed to parse crash report: %@", error);
       return;
    }
    
    NSString *crashReport =
    [PLCrashReportTextFormatter stringValueForCrashReport: report
                                           withTextFormat: PLCrashReportTextFormatiOS];
    NSLog(@"%@", crashReport);

    if (!crashReport) {
        return;
    }
    
    NSMutableArray<RollbarCrashReportData *> *crashReports = [[NSMutableArray alloc] init];
    
    RollbarCrashReportData *crashReportData =
    [[RollbarCrashReportData alloc] initWithCrashReport:crashReport];

    [crashReports addObject:crashReportData];

    [observer onCrashReportsCollectionCompletion:crashReports];
}

@end
