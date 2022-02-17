#ifndef RollbarCrashReportData_h
#define RollbarCrashReportData_h

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/// Models crash report data.
@interface RollbarCrashReportData : NSObject

/// Crash report timestamp.
@property (nonatomic, readonly, nullable) NSDate *timestamp;

/// Crash report content.
@property (nonatomic, readonly, nonnull) NSString *crashReport;

/// Crash report data initializer.
/// @param report crash report content.
-(instancetype)initWithCrashReport:(nonnull NSString *)report;

/// Designated crash report data initializer.
/// @param report crash report content.
/// @param timestamp crash report timestamp.
-(instancetype)initWithCrashReport:(nonnull NSString *)report
                         timestamp:(nullable NSDate *)timestamp
NS_DESIGNATED_INITIALIZER;

/// Hides parameterless initializer.
-(instancetype)init
NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarCrashReportData_h
