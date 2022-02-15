#ifndef RollbarCrashReportUtil_h
#define RollbarCrashReportUtil_h

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, RollbarExceptionInfo) {
    RollbarExceptionInfo_Type,
    RollbarExceptionInfo_Codes,
    RollbarExceptionInfo_Backtraces
};

typedef NS_ENUM(NSUInteger, RollbarBacktraceComponent) {
    RollbarBacktraceComponent_Index = 0,
    RollbarBacktraceComponent_Library,
    RollbarBacktraceComponent_Address,
    RollbarBacktraceComponent_Method,
    RollbarBacktraceComponent_LineNumber
};

@interface RollbarCrashReportUtil : NSObject

+ (nonnull NSArray<NSString *> *)extractLinesFromCrashReport:(nonnull NSString *)report;

+ (nonnull NSDictionary *)extractExceptionInfoFromCrashReport:(nonnull NSString *)crashReport;

+ (nonnull NSDictionary *)extractComponentsFromBacktrace:(nonnull NSString *)backtrace;

#pragma mark - Initializers

- (instancetype _Nonnull )init
NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

#endif /* RollbarCrashReportUtil_h */

