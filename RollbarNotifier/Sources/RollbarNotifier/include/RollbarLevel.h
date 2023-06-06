#ifndef RollbarLevel_h
#define RollbarLevel_h

@import Foundation;

#pragma mark - RollbarLevel

typedef NS_ENUM(NSUInteger, RollbarLevel) {
    RollbarLevel_Debug,
    RollbarLevel_Info,
    RollbarLevel_Warning,
    RollbarLevel_Error,
    RollbarLevel_Critical
};

#pragma mark - RollbarLevel utility

NS_ASSUME_NONNULL_BEGIN

/// RollbarLevel utility
@interface RollbarLevelUtil : NSObject

/// Converts RollbarLevel enum value to its string equivalent or default string.
/// @param value RollbarLevel enum value
+ (NSString *)rollbarLevelToString:(RollbarLevel)value;

/// Converts string value into its  RollbarLevel enum value equivalent or default enum value.
/// @param value input string
+ (RollbarLevel)rollbarLevelFromString:(nullable NSString *)value;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarLevel_h
