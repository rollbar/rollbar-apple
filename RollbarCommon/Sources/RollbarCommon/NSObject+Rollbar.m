#import "NSObject+Rollbar.h"

@implementation NSObject (Rollbar)

- (nonnull NSString *)rollbar_objectClassName {
    
    return NSStringFromClass(self.class);
}

@end
