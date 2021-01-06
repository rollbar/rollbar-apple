//
//  RollbarCrashReportUtil.m
//  
//
//  Created by Andrey Kornich on 2021-01-04.
//

#import "RollbarCrashReportUtil.h"

typedef NS_ENUM(NSUInteger, CrashReportBlock) {
    CrashReportBlock_Start,
    CrashReportBlock_Header,
    CrashReportBlock_Exception,
    CrashReportBlock_ThreadStacks,
    //CrashReportBlock_Thread,
    CrashReportBlock_CrashedThread,
    CrashReportBlock_CrashedThreadState,
    CrashReportBlock_BinaryImages,
    CrashReportBlock_End
};

@implementation RollbarCrashReportUtil

+ (nonnull NSArray<NSString *> *)extractLinesFromCrashReport:(nonnull NSString *)report {
    
    NSArray<NSString *> *reportLines = [report componentsSeparatedByString:@"\n"];
    if (!reportLines) {
        reportLines = [NSArray new];
    }
    return reportLines;
}

+ (nonnull NSDictionary *)extractExceptionInfoFromCrashReport:(nonnull NSString *)crashReport {

    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    CrashReportBlock reportBlock = CrashReportBlock_Header;
    NSArray<NSString *> *reportLines = [RollbarCrashReportUtil extractLinesFromCrashReport:crashReport];
    NSMutableArray<NSString *> *backtraces = [NSMutableArray array];
    for(NSString *reportLine in reportLines) {
        switch (reportBlock) {
            case CrashReportBlock_Start:
            case CrashReportBlock_Header:
                if ([reportLine hasPrefix:@"Exception Type:"]) {
                    reportBlock = CrashReportBlock_Exception;
                    results[@(RollbarExceptionInfo_Type)] = [reportLine copy];
                }
                break;
            case CrashReportBlock_Exception:
                if ([reportLine hasPrefix:@"Exception Codes:"]) {
                    results[@(RollbarExceptionInfo_Codes)] = [reportLine copy];
                }
                else if (reportLine == nil || reportLine.length == 0) {
                    reportBlock = CrashReportBlock_ThreadStacks;
                }
                break;
            case CrashReportBlock_ThreadStacks:
                if ([reportLine hasPrefix:@"Thread "] && [reportLine hasSuffix:@" Crashed:"]) {
                    reportBlock = CrashReportBlock_CrashedThread;
                }
                break;
            case CrashReportBlock_CrashedThread:
                if (reportLine && reportLine.length > 0) {
                    [backtraces addObject:reportLine];
                }
                else {
                    // We reached the end of the exception backtrace.
                    // We got all we needed.
                    // Let's capture the backtraces and get out:
                    results[@(RollbarExceptionInfo_Backtraces)] = [backtraces copy];
                    return [results copy];
                }
                break;
            case CrashReportBlock_CrashedThreadState:
                break;
            case CrashReportBlock_BinaryImages:
                break;
            case CrashReportBlock_End:
                break;
        }
    }
    
    // Let's return whatever we've got so far:
    return [results copy];
}

@end
