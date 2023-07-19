import SwiftUI
import RollbarNotifier

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
