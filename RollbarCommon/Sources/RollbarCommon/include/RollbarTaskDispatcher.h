#ifndef RollbarTaskDispatcher_h
#define RollbarTaskDispatcher_h

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/// Pattern Description:
/// A very generic implementation of the Receptionist design pattern that addresses the general problem of redirecting a task defined in one execution context
/// to be executed/handled within  another execution context.
///
/// When to use the Pattern:
/// You can adopt the Receptionist design pattern whenever you need to bounce off work to another execution context for handling.
/// When you observe a notification, or implement a block handler, or respond to an action message and you want to ensure that your code executes in the
/// appropriate execution context, you can implement the Receptionist pattern to redirect the work that must be done to that execution context.
/// With the Receptionist pattern, you might even perform some filtering or coalescing of the incoming data before you bounce off a task to process the data.
/// For example, you could collect data into batches, and then at intervals dispatch those batches elsewhere for processing.
///
/// Usage Example:
///
/// RollbarTaskDispatcher *dispatcher =
///     [RollbarTaskDispatcher dispatcherForQueue: mainQueue
///                                  task: ^(id taskInput) {
///                                    // cast taskInput to one or more expected type
///                                    // ...
///                                    // handle each specific input type
///                                    // ...
///                                  }
///                              taskInput: concreteTaskInput
///                              ];

/// Defines a generic task block type
typedef void (^RollbarTaskBlock)(id taskInput);

/// Models a task dispatcher.
@interface RollbarTaskDispatcher : NSObject {
    @private
        RollbarTaskBlock _task;
        NSOperationQueue *_queue;
        id _taskInput;
}

/// Creates a dispatcher with specific attributes.
/// @param queue a queue to dispatch to.
/// @param task a task
/// @param taskInput task input data
+ (instancetype)dispatcherForQueue:(NSOperationQueue *)queue
                              task:(RollbarTaskBlock)task
                         taskInput:(id)taskInput;

/// Dispatches the specified task with the specified input.
/// @param task a task
/// @param taskInput an input
- (void)dispatchTask:(RollbarTaskBlock)task
               input:(id)taskInput;

/// Dispatches preconfigured task with the provided input
/// @param taskInput a task input
- (void)dispatchInput:(id)taskInput;

/// Dispatches based on preconfigured queue, task, and input.
- (void)dispatch;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarTaskDispatcher_h
