//
//  RollbarPLCrashCollector.m
//  
//
//  Created by Andrey Kornich on 2020-12-21.
//
@import CrashReporter;
@import RollbarCommon;

#import "RollbarPLCrashCollector.h"
#import "RollbarCrashReportData.h"

@implementation RollbarPLCrashCollector

static PLCrashReporter *sharedPLCrashReporter = nil;

+(void)initialize {
    
    if (self == [RollbarPLCrashCollector class]) {
        
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
        
        // Allocate and init the PLCrashReporter:
        sharedPLCrashReporter =
        [[PLCrashReporter alloc] initWithConfiguration: config];
        
        // Enable the reporter:
        BOOL success = [sharedPLCrashReporter enableCrashReporter];
        if (!success) {
            RollbarSdkLog(@"Couldn't enable PLCrashReporter!");
        }
    }
}

-(void)collectCrashReportsWithObserver:(NSObject<RollbarCrashCollectorObserver> *)observer {
    
    if (!sharedPLCrashReporter || ![sharedPLCrashReporter hasPendingCrashReport]) {
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
    [sharedPLCrashReporter loadPendingCrashReportDataAndReturnError: &error];
    if (data == nil) {
        NSLog(@"Failed to load crash report data: %@", error);
        return;
    }
    [sharedPLCrashReporter purgePendingCrashReport];

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
