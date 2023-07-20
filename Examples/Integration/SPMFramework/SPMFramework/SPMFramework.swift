import SwiftUI
import RollbarNotifier

public struct SPMFramework {
    public static func start() {
        let config = RollbarConfig.mutableConfig(withAccessToken: "[ACCESSTOKEN]")
        config.developerOptions.suppressSdkInfoLogging = false

        Rollbar.initWithConfiguration(config)
    }
}

public struct HelloWorld: View {
    private var title: String

    public init(title: String) {
        self.title = title
    }

    public var body: some View {
        VStack {
            Text(self.title)
        }
        .padding()
        .onAppear {
            Rollbar.infoMessage("SomeView Appeared")
        }
    }
}
