@import RollbarNotifier;

#import "ViewController.h"

@implementation ViewController

- (IBAction)abort:(UIButton *)sender {
    abort(); // SIGABRT
}

- (IBAction)exit:(UIButton *)sender {
    exit(1);
}

- (IBAction)assert:(UIButton *)sender {
    assert(NO);
}

- (IBAction)nsassert:(UIButton *)sender {
    NSAssert(NO, @"whoops");
}

- (IBAction)throw:(UIButton *)sender {
    @throw NSInternalInconsistencyException;
}

- (IBAction)dispatch:(UIButton *)sender {
    dispatch_sync(dispatch_get_main_queue(), ^{});
}

- (IBAction)divideByZero:(UIButton *)sender {
    __unused int i = 1 / 0;
    //div_t i = div(1, 0);
}

- (IBAction)outOfBounds:(UIButton *)sender {
    __unused id n = @[@0][INT_MAX];
}

- (IBAction)null:(UIButton *)sender {
    ((char *)NULL)[1] = 0;
}

- (IBAction)tryCatchFinally:(UIButton *)sender {
    @try {
        NSArray *items = @[@"one", @"two", @"three"];
        __unused NSString *item = items[4];
    } @catch (NSException *exception) {
        [Rollbar errorException:exception
                           data:nil
                        context:@"from @try-@catch"];
    } @finally {
        [Rollbar infoMessage:@"Finally notification"
                        data:nil
                     context:@"from @try-@finally"];
    }
}

- (IBAction)performAbsurdSelector:(UIButton *)sender {
    [self performSelector:@selector(absurd)];
}

- (IBAction)invalidJson:(UIButton *)sender {
    NSError *error;
    __unused NSDictionary *payload =
        [NSJSONSerialization JSONObjectWithData:[[NSData alloc] init]
                                        options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves
                                          error:&error];

    [Rollbar log:RollbarLevel_Error
           error:error
            data:nil
         context:@"While trying to serialize data."];
}

@end
