import XCTest
import Foundation
@testable import RollbarCommon

final class NSJSONSerializationRollbarTests: XCTestCase {
    
    func testNSJSONSerializationRollbar_measureJSONDataByteSize() {
        
        let data = [
            "body": "Message",
            "attribute": "An attribute",
        ];

        let payload = [
            "access_token": "321",
            "data": data,
            ] as [String : Any];
        
        do {
            let nsData = try JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted);
            XCTAssertEqual(103, JSONSerialization.rollbar_measureJSONDataByteSize(nsData));
        }
        catch {
            XCTFail("Unexpected failure!");
        }        
    }
    
    func testNSJSONSerializationRollbar_dataWithJSONObject() {
        // The testNSJSONSerializationRollbar_safeDataFromJSONObject() covers this one as well.
        // At least for now...
    }
    
    func testNSJSONSerializationRollbar_safeDataFromJSONObject() {
        let goldenStandard =
            "{\"access_token\":\"321\",\"data\":{\"attribute\":\"An attribute\",\"body\":\"Message\",\"date\":\"1970-01-01 00:00:00 +0000\",\"error\":{},\"httpUrlResponse\":{\"header1\":\"Header 1\",\"header2\":\"Header 2\"},\"innerData\":{\"attribute\":\"An attribute\",\"body\":\"Message\",\"date\":\"1970-01-01 00:00:00 +0000\",\"error\":{},\"httpUrlResponse\":{\"header1\":\"Header 1\",\"header2\":\"Header 2\"},\"optionalField\":null,\"scrubFields\":\"secret,CCV,password\",\"url\":\"http:\\/\\/www.apple.com\"},\"optionalField\":null,\"scrubFields\":\"secret,CCV,password\",\"url\":\"http:\\/\\/www.apple.com\"}}";

        var data = [
            "body": "Message",
            "optionalField": (nil as String?) as Any,
            "attribute": "An attribute",
            "date": Date(timeIntervalSince1970: TimeInterval.init()),
            "url": URL(string: "http://www.apple.com")!,
            "error": NSError(domain: "Error Domain", code: 101, userInfo: nil),
            "httpUrlResponse": HTTPURLResponse(
                url: URL(string: "https://www.rollbar.com")!,
                statusCode: 500,
                httpVersion: "1.2",
                headerFields: ["header1": "Header 1", "header2": "Header 2"]) as Any,
            "scrubFields": NSSet(array: ["password", "secret", "CCV"]),
        ] as [String: Any];

        data["innerData"] = JSONSerialization.rollbar_data(
            withJSONObject: data,
            options: .sortedKeys,
            error: nil,
            safe: true)

        let payload = [
            "access_token": "321",
            "data": data,
        ] as [String : Any];

        let safeJson = JSONSerialization.rollbar_safeData(fromJSONObject: payload);

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: safeJson, options: .sortedKeys)
            let result = String(data: jsonData, encoding: .utf8);
            XCTAssertEqual(goldenStandard, result);
        }
        catch {
            XCTFail("Unexpected failure!");
        }
    }
    
    static var allTests = [
        ("testNSJSONSerializationRollbar_measureJSONDataByteSize", testNSJSONSerializationRollbar_measureJSONDataByteSize),
        ("testNSJSONSerializationRollbar_dataWithJSONObject", testNSJSONSerializationRollbar_dataWithJSONObject),
        ("testNSJSONSerializationRollbar_safeDataFromJSONObject", testNSJSONSerializationRollbar_safeDataFromJSONObject),
    ]
}
