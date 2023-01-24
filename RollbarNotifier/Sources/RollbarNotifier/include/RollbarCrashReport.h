#ifndef RollbarCrashReport_h
#define RollbarCrashReport_h

@import RollbarCommon;

NS_ASSUME_NONNULL_BEGIN

/// Crash report payload element
@interface RollbarCrashReport : RollbarDTO

/// A well-formed human-readable string suitable to use as a title for an Item
/// and Occurrence.
@property (strong, nonnull, readonly) NSString *title;

/// A well-formed human-readable string with the best possible explanation for
/// why the crash happened.
@property (strong, nonnull, readonly) NSString *diagnostic;

/// Initializer
/// @param rawCrashReport raw crash report content
-(instancetype)initWithRawCrashReport:(nonnull NSString *)rawCrashReport;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarCrashReport_h
