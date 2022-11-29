//
//  ContentView.swift
//  macosAppSwift
//
//  Created by Andrey Kornich on 2021-03-11.
//

import SwiftUI
import RollbarNotifier
import RollbarSwift
import RollbarAUL

struct ContentView: View {
    
    var body: some View {
        
        VStack(content: {
            
            Text("Hello, world!")
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Handle Swift Error") {
                self.handleSwiftError()
            }
            
            Button("Handle Obj-C Exception") {
                self.handleObjCException()
            }
            
            Button("Handle Obj-C Exception with Rollbar") {
                self.handleObjCExceptionWithRollbar()
            }
        })
    }
    
func handleSwiftError() {
    
        do {
            
            try self.generateSwiftError();
        }
        catch AppError.problem1 {
            
        }
        catch AppError.problem2 {
            
        }
        catch {
            
            print("Unexpected error: \(error).")
        }
    }
    
    func generateSwiftError() throws {
        
        throw AppError.limitExceeded(limit: 5)
    }
    
    func handleObjCException() {
        
        self.generateObjCException();
    }
        
    func generateObjCException() {
        
        RollbarTryCatch.throw("NSException from Obj-C...")
    }

    func handleObjCExceptionWithRollbar() {
        
        let exceptionGuard = createGuard();
        
        var success = true;
        
        success = exceptionGuard.tryExecute {
            
            self.generateObjCException();
        }

        print("Guarded execution succeeded: \(success).")
    }
    
    func createGuard() -> RollbarExceptionGuard {
        
        let config = RollbarConfig.mutableConfig(
            withAccessToken: RollbarDemoSettings.payloadsPostAccessToken,
            environment: RollbarDemoSettings.environment)
        
        // AUL capture setup:
//        config.developerOptions.transmit = true;
//        config.telemetry.enabled = true;
//        config.telemetry.captureLog = true;
//
//        Rollbar.initWithConfiguration(config);
//        RollbarAulStoreMonitor.sharedInstance().configureRollbarLogger(Rollbar.currentLogger());
//        let aulOptions = RollbarAulStoreMonitorOptions();
//        aulOptions.addAulSubsystem("DataAccessLayer");
//        aulOptions.addAulSubsystem("Model");
//        aulOptions.addAulCategory("CompanyOrg");
//        RollbarAulStoreMonitor.sharedInstance().configure(with: aulOptions);
//
//        RollbarAulStoreMonitor.sharedInstance().start();
        
        let logger = RollbarLogger(configuration: config);
        
        let exceptionGuard = RollbarExceptionGuard(logger: logger);

        return exceptionGuard;
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ContentView()
    }
}

// Declare our error type
enum AppError: Error {
    case problem1
    case problem2
    case limitExceeded(limit: Int)
}
