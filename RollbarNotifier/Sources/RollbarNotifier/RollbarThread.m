@import RollbarCommon;

#import "RollbarThread.h"
#import "RollbarLogger.h"
#import "RollbarConfig.h"
#import "RollbarDeveloperOptions.h"

@implementation RollbarThread {
    @private RollbarLogger *_logger;
    @private NSUInteger _maxReportsPerMinute;
    @private NSTimer *_timer;
}

- (instancetype)initWithNotifier:(RollbarLogger*)logger
                   reportingRate:(NSUInteger)reportsPerMinute {
    
    if ((self = [super initWithTarget:self
                             selector:@selector(run)
                               object:nil])) {
        
        self.name = @"RollbarThread";
        _logger = logger;
        
        if(reportsPerMinute > 0) {
            _maxReportsPerMinute = reportsPerMinute;
        } else {
            _maxReportsPerMinute = 60;
        }
        
        self.active = YES;
    }
    
    return self;
}

- (void)checkItems {
    
    if (self.cancelled) {
        if (_timer) {
            [_timer invalidate];
            _timer = nil;
        }
        [NSThread exit];
    }
    
    @autoreleasepool {
        
        if ((nil != _logger) && (NO == _logger.configuration.developerOptions.suppressSdkInfoLogging)) {
        
            RollbarSdkLog(@"Checking items...");
        }
        
        [_logger processSavedItems];
    }
}

- (void)run {
    
    @autoreleasepool {
        
        NSTimeInterval timeIntervalInSeconds = 60.0 / _maxReportsPerMinute;
        
        _timer = [NSTimer timerWithTimeInterval:timeIntervalInSeconds
                                        target:self
                                      selector:@selector(checkItems)
                                      userInfo:nil
                                       repeats:YES
                 ];
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addTimer:_timer forMode:NSDefaultRunLoopMode];
        
        while (self.active) {
            [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
}

@end
