#ifndef RollbarPrototype_h
#define RollbarPrototype_h

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/// Prototype pattern protocol.
@protocol RollbarPrototype <__covariant Type>

/// Protoype cloning method.
- (__kindof Type)clone;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarPrototype_h
