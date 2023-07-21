import SwiftUI
import RollbarNotifier

@main
struct CocoapodsApp: App {
    init() {
        let config = RollbarConfig.mutableConfig(withAccessToken: "ACCESSTOKEN")
        config.developerOptions.suppressSdkInfoLogging = false

        Rollbar.initWithConfiguration(config)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
