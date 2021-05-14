//
//  RollbarTaskDispatcher.m
//  
//
//  Created by Andrey Kornich on 2020-10-09.
//

#import "RollbarTaskDispatcher.h"

@implementation RollbarTaskDispatcher

#pragma mark - Properties

#pragma mark - Lifecycle

+ (instancetype)dispatcherForQueue:(NSOperationQueue *)queue
                              task:(RollbarTaskBlock)task
                         taskInput:(id)taskInput {
    
    RollbarTaskDispatcher *dispatcher = [RollbarTaskDispatcher new];
    dispatcher->_task = [task copy];
    dispatcher->_queue = queue;
    dispatcher->_taskInput = taskInput;
    
    return dispatcher;
}

#pragma mark - Operations

- (void)dispatchTask:(RollbarTaskBlock)task input:(id)taskInput {
    
    [self->_queue addOperationWithBlock:^{
        self->_task(self->_taskInput);
    }];
}

- (void)dispatchInput:(id)taskInput {
    
    [self dispatchTask:self->_task input:taskInput];
}

- (void)dispatch {
    [self dispatchInput:self->_taskInput];
}

#pragma mark - NSObject

- (NSString *)description {
    return super.description;
}

@end
