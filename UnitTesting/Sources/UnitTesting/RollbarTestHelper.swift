import Foundation

@objc public class RollbarTestHelper: NSObject {
    
    private static let rollbarUnitTestEnvironment = "Rollbar-Apple-UnitTests";
    private static let rollbarUnitTestPayloadsAccessToken = "09da180aba21479e9ed3d91e0b8d58d6";
    private static let rollbarUnitTestDeploysWriteAccessToken = "efdc4b85d66045f293a7f9e99c732f61";
    private static let rollbarUnitTestDeploysReadAccessToken = "595cbf76b05b45f2b3ef661a2e0078d4";

    
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
