//
//  RollbarDeploysDemoClient.m
//  macosAppObjC
//
//  Created by Andrey Kornich on 2020-05-22.
//  Copyright © 2020 Andrey Kornich (Wide Spectrum Computing LLC). All rights reserved.
//

#import "RollbarDeploysDemoClient.h"
#import "RollbarDemoSettings.h"
@import RollbarDeploys;

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
    
    NSString * const environment = ROLLBAR_DEMO_ENVIRONMENT;
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
