#ifndef RollbarRawCrashReport_h
#define RollbarRawCrashReport_h

@import RollbarCommon;

NS_ASSUME_NONNULL_BEGIN

/// Crash report payload element
@interface RollbarRawCrashReport : RollbarDTO

#pragma mark - Properties

/// Required: raw crash report content
/// The raw crash report, as a string
/// Rollbar expects the format generated by this SDK
@property (nonatomic, nonnull) NSString *rawCrashReport;

#pragma mark - Initializers

/// Initializer
/// @param rawCrashReport raw crash report content
-(instancetype)initWithRawCrashReport:(nonnull NSString *)rawCrashReport;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarRawCrashReport_h
