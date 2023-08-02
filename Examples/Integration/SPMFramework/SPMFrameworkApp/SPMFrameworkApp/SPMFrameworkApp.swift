import SwiftUI
import SPMFramework

@main
struct SPMFrameworkApp: App {
    init() {
        SPMEntryPoint.start()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
