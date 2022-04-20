#ifndef RollbarCallStackFrameContext_h
#define RollbarCallStackFrameContext_h

@import RollbarCommon;

NS_ASSUME_NONNULL_BEGIN

/// RollbarCallStackFrameContext payload element
@interface RollbarCallStackFrameContext : RollbarDTO

#pragma mark - Properties

/// Optional: pre
/// List of lines of code before the "code" line
@property (nonatomic, nullable) NSArray<NSString *> *preCodeLines;

/// Optional: post
/// List of lines of code after the "code" line
@property (nonatomic, nullable) NSArray<NSString *> *postCodeLines;

#pragma mark - Initializers

/// Initializer
/// @param pre preceding lines of code
/// @param post post/trailing lines of code
-(instancetype)initWithPreCodeLines:(nullable NSArray<NSString *> *)pre
                     postCodeLines:(nullable NSArray<NSString *> *)post;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarCallStackFrameContext_h
