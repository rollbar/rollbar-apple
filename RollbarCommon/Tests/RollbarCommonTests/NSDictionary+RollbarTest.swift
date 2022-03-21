import XCTest
import Foundation
import RollbarCommon
@testable import RollbarCommon

final class NSDictionaryRollbarTests: XCTestCase {

    func testNSDictionaryRollbar_keyPresent() {

        let data:NSDictionary = [
            "key1": "Value 1",
            "key2": "Value 2",
            "key3": NSNull(),
        ];
        
        XCTAssertTrue(data.rollbar_valuePresent(
            forKey: "key1",
            withContext: self.rollbar_objectClassName()
        ));
        XCTAssertTrue(data.rollbar_valuePresent(
            forKey: "key2",
            withContext: self.rollbar_objectClassName()
        ));
        XCTAssertFalse(data.rollbar_valuePresent(
            forKey: "key3",
            withContext: self.rollbar_objectClassName()
        ));
        XCTAssertFalse(data.rollbar_valuePresent(
            forKey: "non-existent-key",
            withContext: self.rollbar_objectClassName()
        ));
    }
    
    static var allTests = [
        ("testNSDictionaryRollbar_keyPresent", testNSDictionaryRollbar_keyPresent),
    ]
}
