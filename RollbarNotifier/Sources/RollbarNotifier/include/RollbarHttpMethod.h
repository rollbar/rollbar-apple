@import Foundation;

#pragma mark - RollbarHttpMethod enum

typedef NS_ENUM(NSUInteger, RollbarHttpMethod) {
    RollbarHttpMethod_Head,
    RollbarHttpMethod_Get,
    RollbarHttpMethod_Post,
    RollbarHttpMethod_Put,
    RollbarHttpMethod_Patch,
    RollbarHttpMethod_Delete,
    RollbarHttpMethod_Connect,
    RollbarHttpMethod_Options,
    RollbarHttpMethod_Trace,
};

#pragma mark - RollbarHttpMethodUtil

NS_ASSUME_NONNULL_BEGIN

/// HTTP method enum converter unitilty
@interface RollbarHttpMethodUtil : NSObject

/// Convert RollbarHttpMethod to a string
/// @param value RollbarHttpMethod value
+ (nonnull NSString *) HttpMethodToString:(RollbarHttpMethod)value;

/// Convert RollbarHttpMethod value from a string
/// @param value string representation of a RollbarHttpMethod value
+ (RollbarHttpMethod) HttpMethodFromString:(nullable NSString *)value;

@end

NS_ASSUME_NONNULL_END
