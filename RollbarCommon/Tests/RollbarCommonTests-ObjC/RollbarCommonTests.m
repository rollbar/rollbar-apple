@import Foundation;

#import <XCTest/XCTest.h>

@import RollbarCommon;
#import "Mocks/Calculator.h"

@interface RollbarCommonTests : XCTestCase

@end

@implementation RollbarCommonTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSLog(@"Set to go...");
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    NSLog(@"Teared down.");
}

- (void)testSetDictionaryWithNothing {
    
    RollbarDTO *dto = [[RollbarDTO alloc] initWithDictionary:@{}];
    XCTAssertNotNil(dto);
    XCTAssertNil([dto getDataByKey:@"key"]);

    [dto setDictionary:NULL forKey:@"key"];
    XCTAssertNil([dto getDataByKey:@"key"]);
    
    [dto setDictionary:Nil forKey:@"key"];
    XCTAssertNil([dto getDataByKey:@"key"]);
    
    [dto setDictionary:nil forKey:@"key"];
    XCTAssertNil([dto getDataByKey:@"key"]);
    
    [dto setDictionary:@{} forKey:@"key"];
    XCTAssertNotNil([dto getDataByKey:@"key"]);
}

//- (void)testRollbarTaskDispatcher {
//
//    void (^task)(id) = ^(id taskInput) {
//        NSLog(@"Processing thread: %@", [NSThread currentThread]);
//        Calculator *calc = (Calculator *)taskInput;
//        if (calc != nil) {
//            [calc calculate];
//        }
//    };
//
//    NSOperationQueue *processingQueue = [NSOperationQueue currentQueue];
//    processingQueue.maxConcurrentOperationCount = 10;
//    for( int i = 0; i < 5; i++) {
//        for (int j = 1; j < 5; j++) {
//            NSString *expectationLabel = nil;
//            XCTestExpectation *expectation = nil;
//
//            expectationLabel = [NSString stringWithFormat:@"asynchronous request: %i + %i", i, j];
//            expectation = [self expectationWithDescription: expectationLabel];
//            dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY,0), ^(){
//                NSLog(@"Sending thread: %@", [NSThread currentThread]);
//                Calculator * taskInput;
//                taskInput = [[Calculator alloc] initWithOperation:CalculatorOperation_Add
//                                                         operand1:i
//                                                         operand2:j
//                                                      expectation:expectation];
//                [[RollbarTaskDispatcher dispatcherForQueue:processingQueue
//                                                      task:task
//                                                 taskInput:taskInput]
//                 dispatch];
//                [NSThread sleepForTimeInterval:0.01f];
//            });
//
//            expectationLabel = [NSString stringWithFormat:@"asynchronous request: %i - %i", i, j];
//            expectation = [self expectationWithDescription: expectationLabel];
//            dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY,0), ^(){
//                NSLog(@"Sending thread: %@", [NSThread currentThread]);
//                Calculator * taskInput;
//                taskInput = [[Calculator alloc] initWithOperation:CalculatorOperation_Subtract
//                                                         operand1:i
//                                                         operand2:j
//                                                      expectation:expectation];
//                [[RollbarTaskDispatcher dispatcherForQueue:processingQueue
//                                                      task:task
//                                                 taskInput:taskInput]
//                 dispatch];
//                [NSThread sleepForTimeInterval:0.01f];
//            });
//
//            expectationLabel = [NSString stringWithFormat:@"asynchronous request: %i * %i", i, j];
//            expectation = [self expectationWithDescription: expectationLabel];
//            dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY,0), ^(){
//                NSLog(@"Sending thread: %@", [NSThread currentThread]);
//                Calculator * taskInput;
//                taskInput = [[Calculator alloc] initWithOperation:CalculatorOperation_Multiply
//                                                         operand1:i
//                                                         operand2:j
//                                                      expectation:expectation];
//                [[RollbarTaskDispatcher dispatcherForQueue:processingQueue
//                                                      task:task
//                                                 taskInput:taskInput]
//                 dispatch];
//                [NSThread sleepForTimeInterval:0.01f];
//            });
//
//            expectationLabel = [NSString stringWithFormat:@"asynchronous request: %i / %i", i, j];
//            expectation = [self expectationWithDescription: expectationLabel];
//            dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY,0), ^(){
//                NSLog(@"Sending thread: %@", [NSThread currentThread]);
//                Calculator * taskInput;
//                taskInput = [[Calculator alloc] initWithOperation:CalculatorOperation_Divide
//                                                         operand1:i
//                                                         operand2:j
//                                                      expectation:expectation];
//                [[RollbarTaskDispatcher dispatcherForQueue:processingQueue
//                                                      task:task
//                                                 taskInput:taskInput]
//                 dispatch];
//                [NSThread sleepForTimeInterval:0.01f];
//            });
//        }
//    }
//
//    [self waitForExpectationsWithTimeout:0.1f handler:^(NSError *error){
//        if (error){
//            XCTFail(@"Failed expectations fulfillment!");
//        }
//    }];
//}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
