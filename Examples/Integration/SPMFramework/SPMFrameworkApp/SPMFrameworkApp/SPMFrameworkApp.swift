import SwiftUI
import SPMFramework

@main
struct SPMFrameworkApp: App {
    init() {
        SPMFramework.start()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
