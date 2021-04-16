//
//  AppDelegate.swift
//  macosAppSwiftCocoapods
//
//  Created by Andrey Kornich on 2020-06-17.
//  Copyright © 2020 Andrey Kornich (Wide Spectrum Computing LLC). All rights reserved.
//

import Cocoa
import RollbarNotifier
import RollbarPLCrashReporter
import SwiftTryCatch2

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        self.demonstrateDeployApiUasege();
        self.initRollbar();
        
        SwiftTryCatch.tryRun({
            self.callTroublemaker();
        },
        catchRun: { (exception) in
            Rollbar.log(RollbarLevel.error, exception: exception!)
        },
        finallyRun: {
            Rollbar.log(RollbarLevel.info, message:"Post-trouble notification!");
        })
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        Rollbar.log(RollbarLevel.info, message:"The hosting application is terminating...");
    }

    func initRollbar() {

        // configure Rollbar:
        let config = RollbarConfig();
        //config.crashLevel = @"critical";
        config.destination.accessToken = "2ffc7997ed864dda94f63e7b7daae0f3";
        config.destination.environment = "samples";
        config.customData = [ "someKey": "someValue", ];
        
        //let crashCollector = RollbarPLCrashCollector();
        
        // init Rollbar shared instance:
        Rollbar.initWithConfiguration(config, crashCollector: nil);//crashCollector);
        Rollbar.log(RollbarLevel.info,
                    message:"Rollbar is up and running! Enjoy your remote error and log monitoring...");
    }

    func demonstrateDeployApiUasege() {
        
        let rollbarDeploysIntro = RollbarDeploysDemoClient();
        rollbarDeploysIntro.demoDeploymentRegistration();
        rollbarDeploysIntro.demoGetDeploymentDetailsById();
        rollbarDeploysIntro.demoGetDeploymentsPage();
    }

    func callTroublemaker() {
        SwiftTryCatch.throw(
            NSException(name: NSExceptionName("Incoming ObjC exception!!!"), reason: "Why not?", userInfo: nil)
        );
//        let items = ["one", "two", "three"];
//        print("Here is the trouble-item: \(items[10])");
    }
}

