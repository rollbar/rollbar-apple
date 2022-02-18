@import Foundation;

#pragma mark - RollbarSource enum

typedef NS_ENUM(NSUInteger, RollbarSource) {
    RollbarSource_Client,
    RollbarSource_Server,
};

#pragma mark - RollbarSourceUtil

NS_ASSUME_NONNULL_BEGIN

@interface RollbarSourceUtil : NSObject

/// Convert RollbarSource to a string
/// @param value RollbarSource value
+ (NSString *) RollbarSourceToString:(RollbarSource)value;

/// Convert RollbarSource value from a string
/// @param value string representation of a RollbarSource value
+ (RollbarSource) RollbarSourceFromString:(nullable NSString *)value;

@end

NS_ASSUME_NONNULL_END
