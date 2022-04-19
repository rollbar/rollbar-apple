import XCTest
import Foundation
@testable import RollbarCommon

final class RollbarMemoryStatsDescriptorsTests: XCTestCase {
    
    func testRollbarMemoryStatsDescriptors_basics() {
        
        XCTAssertEqual(
            "physical",
            RollbarMemoryStatsDescriptors.sharedInstance().getMemoryStatsTypeDescriptor(RollbarMemoryStatsType.physical)
        );
        XCTAssertEqual(
            "vm",
            RollbarMemoryStatsDescriptors.sharedInstance().getMemoryStatsTypeDescriptor(RollbarMemoryStatsType.VM)
        );
        
        XCTAssertEqual(
            "total_MB",
            RollbarMemoryStatsDescriptors.sharedInstance().getPhysicalMemoryDescriptor(RollbarPhysicalMemory.totalMB)
        );
        
        XCTAssertEqual(
            "free_MB",
            RollbarMemoryStatsDescriptors.sharedInstance().getVirtualMemoryDescriptor(RollbarVirtualMemory.freeMB)
        );
        XCTAssertEqual(
            "active_MB",
            RollbarMemoryStatsDescriptors.sharedInstance().getVirtualMemoryDescriptor(RollbarVirtualMemory.activeMB)
        );
        XCTAssertEqual(
            "inactive_MB",
            RollbarMemoryStatsDescriptors.sharedInstance().getVirtualMemoryDescriptor(RollbarVirtualMemory.inactiveMB)
        );
        XCTAssertEqual(
            "speculative_MB",
            RollbarMemoryStatsDescriptors.sharedInstance().getVirtualMemoryDescriptor(RollbarVirtualMemory.speculativeMB)
        );
        XCTAssertEqual(
            "wired_MB",
            RollbarMemoryStatsDescriptors.sharedInstance().getVirtualMemoryDescriptor(RollbarVirtualMemory.wiredMB)
        );
    }
    
    static var allTests = [
        ("testRollbarMemoryStatsDescriptors_basics", testRollbarMemoryStatsDescriptors_basics),
    ]
}
