import XCTest
import Foundation
@testable import RollbarCommon

final class RollbarMemoryUtilTests: XCTestCase {
    
    func testRollbarMemoryUtil_Basics() throws {
        
        let memoryStats = RollbarMemoryUtil.getMemoryStats();
        
        print(memoryStats);
        
        XCTAssertTrue(memoryStats["physical"] is NSDictionary);
        let physicalMemoryStats = memoryStats["physical"] as! NSDictionary;
        XCTAssertTrue((physicalMemoryStats["total_MB"] as! NSNumber).uintValue > 0);

        XCTAssertTrue(memoryStats["vm"] is NSDictionary);
        let virtualMemoryStats = memoryStats["vm"] as! NSDictionary;
        XCTAssertTrue((virtualMemoryStats["free_MB"] as! NSNumber).uintValue > 0);
        XCTAssertTrue((virtualMemoryStats["active_MB"] as! NSNumber).uintValue > 0);
        XCTAssertTrue((virtualMemoryStats["inactive_MB"] as! NSNumber).uintValue > 0);
        XCTAssertTrue((virtualMemoryStats["speculative_MB"] as! NSNumber).uintValue > 0);
        XCTAssertTrue((virtualMemoryStats["wired_MB"] as! NSNumber).uintValue > 0);
    }
    
    func testRollbarMemoryUtil_Performance() throws {
        
        measure {
            _ = RollbarMemoryUtil.getMemoryStats();
        }
    }
    static var allTests = [
        ("testRollbarMemoryUtil_basics", testRollbarMemoryUtil_Basics),
        ("testPerformance", testRollbarMemoryUtil_Performance)
    ]
}
