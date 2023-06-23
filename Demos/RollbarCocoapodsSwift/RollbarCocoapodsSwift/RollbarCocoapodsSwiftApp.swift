import SwiftUI
//import RollbarCommon
import RollbarCrashReport
import RollbarNotifier
//import RollbarDeploys
//import RollbarCocoaLumberjack

@main
struct RollbarCocoapodsSwiftApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    func uncaught() {
        uncaughtExceptionHandler(NSException())
    }
}
