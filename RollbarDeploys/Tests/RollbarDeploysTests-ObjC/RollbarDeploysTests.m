//  Copyright (c) 2018 Rollbar, Inc. All rights reserved.

#import <XCTest/XCTest.h>
#import "../../../UnitTests/RollbarUnitTestSettings.h"

@import RollbarDeploys;

@interface RollbarDeploysObserver : NSObject
    <RollbarDeploymentRegistrationObserver,
    RollbarDeploymentDetailsObserver,
    RollbarDeploymentDetailsPageObserver>
@end

@implementation RollbarDeploysObserver

- (void)onRegisterDeploymentCompleted:(nonnull RollbarDeploymentRegistrationResult *)result {
    NSLog(@"result: %@", result);
    NSLog(@"result.description: %@", result.description);
    NSLog(@"result.outcome: %li", result.outcome);
    NSLog(@"result.deploymentId: %@", result.deploymentId);
}

- (void)onGetDeploymentDetailsCompleted:(nonnull RollbarDeploymentDetailsResult *)result {
    NSLog(@"result: %@", result);
    NSLog(@"result.description: %@", result.description);
    NSLog(@"result.outcome: %li", result.outcome);
    NSLog(@"result.deployment.deployId: %@", result.deployment.deployId);
    NSLog(@"result.deployment.projectId: %@", result.deployment.projectId);
    NSLog(@"result.deployment.revision: %@", result.deployment.revision);
    NSLog(@"result.deployment.startTime: %@", result.deployment.startTime);
    NSLog(@"result.deployment.endTime: %@", result.deployment.endTime);
}

- (void)onGetDeploymentDetailsPageCompleted:(nonnull RollbarDeploymentDetailsPageResult *)result {
    NSLog(@"result: %@", result);
    NSLog(@"result.description: %@", result.description);
    NSLog(@"result.outcome: %li", result.outcome);
    NSLog(@"result.pageNumber: %li", result.pageNumber);
    NSLog(@"result.deployments.count: %li", result.deployments.count);
    NSLog(@"result.deployments[0].description: %@", result.deployments[0].description);
}

@end


@interface RollbarDeploysTests : XCTestCase
@end

@implementation RollbarDeploysTests

- (void)testDeploymentDto {
    NSString * const environment = ROLLBAR_UNIT_TEST_ENVIRONMENT;
    NSString * const comment = @"a new deploy";
    NSString * const revision = @"a_revision";
    NSString * const localUsername = @"UnitTestRunner";
    NSString * const rollbarUsername = @"rollbar";
    
    RollbarDeployment *deployment = [[RollbarDeployment alloc] initWithEnvironment:environment
                                                                           comment:comment
                                                                          revision:revision
                                                                     localUserName:localUsername
                                                                   rollbarUserName:rollbarUsername];
    
    XCTAssertTrue(nil != deployment.environment);
    XCTAssertTrue(nil != deployment.comment);
    XCTAssertTrue(nil != deployment.revision);
    XCTAssertTrue(nil != deployment.localUsername);
    XCTAssertTrue(nil != deployment.rollbarUsername);
    
    XCTAssertTrue(environment == deployment.environment);
    XCTAssertTrue(comment == deployment.comment);
    XCTAssertTrue(revision == deployment.revision);
    XCTAssertTrue(localUsername == deployment.localUsername);
    XCTAssertTrue(rollbarUsername == deployment.rollbarUsername);
}

- (void)testDeploymentRegistration {
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString * const environment = ROLLBAR_UNIT_TEST_ENVIRONMENT;
    NSString * const comment =
        [NSString stringWithFormat:@"a new deploy at %@", [dateFormatter stringFromDate:[NSDate date]]];
    NSString * const revision = @"a_revision";
    NSString * const localUsername = @"UnitTestRunner";
    NSString * const rollbarUsername = @"rollbar";
    
    RollbarDeploysObserver *observer = [[RollbarDeploysObserver alloc] init];
    RollbarDeployment *deployment = [[RollbarDeployment alloc] initWithEnvironment:environment
                                                                           comment:comment
                                                                          revision:revision
                                                                     localUserName:localUsername
                                                                   rollbarUserName:rollbarUsername];
    RollbarDeploysManager *deploysManager =
        [[RollbarDeploysManager alloc] initWithWriteAccessToken:ROLLBAR_UNIT_TEST_DEPLOYS_WRITE_ACCESS_TOKEN
                                                readAccessToken:ROLLBAR_UNIT_TEST_DEPLOYS_READ_ACCESS_TOKEN
                                 deploymentRegistrationObserver:observer
                                      deploymentDetailsObserver:observer
                                  deploymentDetailsPageObserver:observer
         ];
    [deploysManager registerDeployment:deployment];
}

- (void)testGetDeploymentDetailsById {
    NSString * const testDeploymentId = @"23922850";
    RollbarDeploysObserver *observer = [[RollbarDeploysObserver alloc] init];
    RollbarDeploysManager *deploysManager =
    [[RollbarDeploysManager alloc] initWithWriteAccessToken:ROLLBAR_UNIT_TEST_DEPLOYS_WRITE_ACCESS_TOKEN
                                            readAccessToken:ROLLBAR_UNIT_TEST_DEPLOYS_READ_ACCESS_TOKEN
                             deploymentRegistrationObserver:observer
                                  deploymentDetailsObserver:observer
                              deploymentDetailsPageObserver:observer
     ];
    [deploysManager getDeploymentWithDeployId:testDeploymentId];
}

- (void)testGetDeploymentsPage {
    RollbarDeploysObserver *observer = [[RollbarDeploysObserver alloc] init];
    RollbarDeploysManager *deploysManager =
    [[RollbarDeploysManager alloc] initWithWriteAccessToken:ROLLBAR_UNIT_TEST_DEPLOYS_WRITE_ACCESS_TOKEN
                                            readAccessToken:ROLLBAR_UNIT_TEST_DEPLOYS_READ_ACCESS_TOKEN
                             deploymentRegistrationObserver:observer
                                  deploymentDetailsObserver:observer
                              deploymentDetailsPageObserver:observer
     ];
    [deploysManager getDeploymentsPageNumber:1];
}

@end

