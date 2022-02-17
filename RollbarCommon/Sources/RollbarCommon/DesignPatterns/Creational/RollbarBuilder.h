@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@class RollbarEntityBuilder;

///Immutable entity model
@interface RollbarEntity : NSObject

/// Entity ID
@property (nonnull, nonatomic, readonly) NSString *ID;

/// Designated initializer
/// @param builder an entity builder
- (nonnull instancetype)initWithBuilder:(nonnull RollbarEntityBuilder *)builder
NS_DESIGNATED_INITIALIZER;

/// Hides the method.
- (instancetype)init
NS_UNAVAILABLE;

@end

/// Mutable builder of immutable entities
@interface RollbarEntityBuilder : NSObject

/// Entity ID
@property (nonnull, nonatomic) NSString *ID;

/// The builder method.
- (nonnull RollbarEntity *)build;

@end

NS_ASSUME_NONNULL_END
