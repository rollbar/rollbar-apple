import Foundation

@objc public class RollbarTestHelper: NSObject {
    
    private static let rollbarUnitTestEnvironment = "Rollbar-Apple-UnitTests";
    private static let rollbarUnitTestPayloadsAccessToken = "09da180aba21479e9ed3d91e0b8d58d6";
    private static let rollbarUnitTestDeploysWriteAccessToken = "a63c9c2f61be4746a888e9cad19a7a9f";
    private static let rollbarUnitTestDeploysReadAccessToken = "3520e804c6234873bad3c6b4a8de7476";

    
    @objc public static func getRollbarEnvironment() -> String {
        return RollbarTestHelper.rollbarUnitTestEnvironment;
    }
    
    @objc public static func getRollbarPayloadsAccessToken() -> String {
        return RollbarTestHelper.rollbarUnitTestPayloadsAccessToken;
    }
    
    @objc public static func getRollbarDeploysWriteAccessToken() -> String {
        return RollbarTestHelper.rollbarUnitTestDeploysWriteAccessToken;
    }
    
    @objc public static func getRollbarDeploysReadAccessToken() -> String {
        return RollbarTestHelper.rollbarUnitTestDeploysReadAccessToken;
    }
    
    private override init() {
    }
}
