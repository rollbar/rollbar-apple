import XCTest
import RollbarNotifier
@testable import RollbarSwift

final class RollbarSwiftTests: XCTestCase {
    
    func safeCode() {
        
        NSLog("Nothing dangerous here.");
    }

    func produceObjCException() {
        
        RollbarTryCatch.throw("Fake NSException");
    }
    
    func createGuard() -> RollbarExceptionGuard {
        
        let config = RollbarConfig();
        config.destination.accessToken = "09da180aba21479e9ed3d91e0b8d58d6";
        config.destination.environment = "Rollbar-Apple-UnitTests";
        config.developerOptions.transmit = true;
        
        let logger = RollbarLogger(configuration: config);
        
        let exceptionGuard = RollbarExceptionGuard(logger: logger);

        return exceptionGuard;
    }
    
    func testExceptionGuard_tryExecute() {
        
        let exceptionGuard = createGuard();
        
        var success = true;
        
        success = exceptionGuard.tryExecute {
            
            safeCode();
        }
        
        XCTAssertTrue(success);

        success = exceptionGuard.tryExecute {
            
            produceObjCException();
        }
        
        XCTAssertTrue(!success);
        
        Thread.sleep(forTimeInterval: 2);
    }

    func testExceptionGuard_execute() {
        
        let exceptionGuard = createGuard();
        
        do {
            
            try exceptionGuard.execute {
                
                safeCode();
            };
        } catch {
            
            XCTFail("Should never get here! Completely safe code was tried!");
        }

        do {
            
            try exceptionGuard.execute {
                
                produceObjCException();
            };
        } catch {
            
            NSLog(error.localizedDescription);
            XCTAssertTrue(error.localizedDescription.contains("Fake NSException"));
        }
        
        Thread.sleep(forTimeInterval: 2);
    }

    static var allTests = [
        ("testExceptionGuard_tryExecute", testExceptionGuard_tryExecute),
        ("testExceptionGuard_execute", testExceptionGuard_execute),
    ]
}
