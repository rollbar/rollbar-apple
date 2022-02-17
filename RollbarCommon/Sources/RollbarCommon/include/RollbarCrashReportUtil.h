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

/// Crash report utility.
@interface RollbarCrashReportUtil : NSObject

/// Splits the provided crash report into collection of report lines.
/// @param report a crash report of interest.
+ (nonnull NSArray<NSString *> *)extractLinesFromCrashReport:(nonnull NSString *)report;

/// Extracts exception related info from the provided crash report.
/// @param crashReport a crash report of interest.
+ (nonnull NSDictionary *)extractExceptionInfoFromCrashReport:(nonnull NSString *)crashReport;

/// Splits a backtrace into its individual components
/// @param backtrace a backtrace.
+ (nonnull NSDictionary *)extractComponentsFromBacktrace:(nonnull NSString *)backtrace;

#pragma mark - Initializers

/// Hides parameterless initializer.
- (instancetype _Nonnull )init
NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

#endif /* RollbarCrashReportUtil_h */

