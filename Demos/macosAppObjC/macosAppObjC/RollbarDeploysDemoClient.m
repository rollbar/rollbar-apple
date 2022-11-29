//
//  RollbarDeploysDemoClient.m
//  macosAppObjC
//
//  Created by Andrey Kornich on 2020-05-22.
//  Copyright © 2020 Andrey Kornich (Wide Spectrum Computing LLC). All rights reserved.
//

#import "RollbarDeploysDemoClient.h"
@import RollbarDeploys;

static NSString * const ROLLBAR_DEMO_PAYLOADS_ACCESS_TOKEN = @"09da180aba21479e9ed3d91e0b8d58d6";
static NSString * const ROLLBAR_DEMO_DEPLOYS_WRITE_ACCESS_TOKEN = @"efdc4b85d66045f293a7f9e99c732f61";
static NSString * const ROLLBAR_DEMO_DEPLOYS_READ_ACCESS_TOKEN = @"595cbf76b05b45f2b3ef661a2e0078d4";

@interface RollbarDeploysObserver
    : NSObject<
        RollbarDeploymentRegistrationObserver,
        RollbarDeploymentDetailsObserver,
        RollbarDeploymentDetailsPageObserver
    >
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
    if (result.deployments.count > 0) {
        NSLog(@"result.deployments[0].description: %@", result.deployments[0].description);
    }
}

@end

@implementation RollbarDeploysDemoClient

- (void)demoDeploymentRegistration {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString * const environment = @"staging";
    NSString * const comment =
        [NSString stringWithFormat:@"a new deploy at %@", [dateFormatter stringFromDate:[NSDate date]]];
    NSString * const revision = @"a_revision";
    NSString * const localUsername = @"DemosRunner";
    NSString * const rollbarUsername = @"rollbar";
    
    RollbarDeploysObserver *observer = [[RollbarDeploysObserver alloc] init];
    RollbarDeployment *deployment = [[RollbarDeployment alloc] initWithEnvironment:environment
                                                                           comment:comment
                                                                          revision:revision
                                                                     localUserName:localUsername
                                                                   rollbarUserName:rollbarUsername];
    RollbarDeploysManager *deploysManager =
        [[RollbarDeploysManager alloc] initWithWriteAccessToken:ROLLBAR_DEMO_DEPLOYS_WRITE_ACCESS_TOKEN
                                                readAccessToken:ROLLBAR_DEMO_DEPLOYS_READ_ACCESS_TOKEN
                                 deploymentRegistrationObserver:observer
                                      deploymentDetailsObserver:observer
                                  deploymentDetailsPageObserver:observer
         ];
    [deploysManager registerDeployment:deployment];
}

- (void)demoGetDeploymentDetailsById {
    
    NSString * const testDeploymentId = @"23922850";
    RollbarDeploysObserver *observer = [[RollbarDeploysObserver alloc] init];
    RollbarDeploysManager *deploysManager =
    [[RollbarDeploysManager alloc] initWithWriteAccessToken:ROLLBAR_DEMO_DEPLOYS_WRITE_ACCESS_TOKEN
                                            readAccessToken:ROLLBAR_DEMO_DEPLOYS_READ_ACCESS_TOKEN
                             deploymentRegistrationObserver:observer
                                  deploymentDetailsObserver:observer
                              deploymentDetailsPageObserver:observer
     ];
    [deploysManager getDeploymentWithDeployId:testDeploymentId];
}

- (void)demoGetDeploymentsPage {
    
    RollbarDeploysObserver *observer = [[RollbarDeploysObserver alloc] init];
    RollbarDeploysManager *deploysManager =
    [[RollbarDeploysManager alloc] initWithWriteAccessToken:ROLLBAR_DEMO_DEPLOYS_WRITE_ACCESS_TOKEN
                                            readAccessToken:ROLLBAR_DEMO_DEPLOYS_READ_ACCESS_TOKEN
                             deploymentRegistrationObserver:observer
                                  deploymentDetailsObserver:observer
                              deploymentDetailsPageObserver:observer
     ];
    [deploysManager getDeploymentsPageNumber:1];
}

@end
