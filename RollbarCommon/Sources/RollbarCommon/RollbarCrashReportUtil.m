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
    for (NSString *reportLine in reportLines) {
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

+ (nonnull NSDictionary *)extractComponentsFromBacktrace:(nonnull NSString *)backtrace {
    
    NSMutableDictionary *result =
    [NSMutableDictionary dictionaryWithCapacity:(RollbarBacktraceComponent_LineNumber + 1)];
    
    NSMutableArray *components =
    [backtrace componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
    .mutableCopy;
    [components removeObject:@""];
    
    uint i = RollbarBacktraceComponent_Index;
    while (i <= RollbarBacktraceComponent_Address) {
        result[@(i)] = components[i];
        i++;
    }
    if (components.count > i) {
        // if we got here, the backtrace is symbolicated,
        // let's extract method name and line number:
        NSMutableString *method = [NSMutableString stringWithString:components[i]];
        while(++i < components.count - 1 && ![components[i] isEqualToString:@"+"]) {
            [method appendFormat:@" %@", components[i]];
        }
        result[@(RollbarBacktraceComponent_Method)] = method.copy;
        result[@(RollbarBacktraceComponent_LineNumber)] = components[components.count - 1];
    }
    
    return result.copy;
}

@end
