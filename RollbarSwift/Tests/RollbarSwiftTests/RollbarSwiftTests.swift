import XCTest
@testable import RollbarSwift

final class RollbarSwiftTests: XCTestCase {
    
    func produceObjCException() {
        
        RollbarTryCatch.throw("Fake NSException");
    }
    
    func testExample() {
        
        let config = RollbarConfig();
        config.destination.accessToken = "2ffc7997ed864dda94f63e7b7daae0f3";
        config.destination.environment = "unit-tests";
        config.developerOptions.transmit = true;
        
        let logger = RollbarLogger(configuration: config);
        
        let exceptionGuard = RollbarExceptionGuard(logger: logger);
        
        do {
            try exceptionGuard.tryExecute {
                produceObjCException();
            };
        } catch {
            NSLog(error.localizedDescription);
        }
        
        Thread.sleep(forTimeInterval: 5);
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
