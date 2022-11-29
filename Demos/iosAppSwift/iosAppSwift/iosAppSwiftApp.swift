import SwiftUI
import RollbarSwift
import RollbarNotifier
import RollbarPLCrashReporter

@main
struct iosAppSwiftApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Dynamically read these settings from your config settings on
        // application startup.
        let accessToken = "2fa95b91f38448299b5097ff11cffb23"  // Rollbar post_client_item access token
        let environment = "staging"
        let codeVersion = "main"  // Ideally codeVersion is commit SHA https://docs.rollbar.com/docs/versions

        // Initialize a configuration object and add configuration settings as
        // needed.
        let config = RollbarConfig.mutableConfig(
            withAccessToken: accessToken,
            environment: environment)

        config.loggingOptions.codeVersion = codeVersion

        // Optionally anonymize the IP address
        //config.loggingOptions.captureIp = RollbarCaptureIpType.anonymize

        // Suppress Rollbar event being logged (e.g. in XCode debug logs)
        //config.developerOptions.suppressSdkInfoLogging = true

        config.telemetry.enabled = true
        config.telemetry.captureLog = true
        config.telemetry.maximumTelemetryData = 10

        config.modifyRollbarData = Rollbar.transform(payload:)

        // Optionally don't send certain occurrences based on some aspect of
        // the payload contents
        //config.checkIgnoreRollbarData = Rollbar.shouldIgnore(payload:)

        // List of fields to scrub
        // Make sure to test this if you are overriding the default scrub list
        //config.dataScrubber.scrubFields = ["accessToken", "cpu", "key_y"]

        // optionally add data about the user to improve error response
        config.person.id = "12345"

        // additional custom data to add to every occurrence sent
        config.customData = ["customer_type": "enterprise"]

        // Initialize a Rollbar shared instance with a crash collector
        Rollbar.initWithConfiguration(
            config,
            crashCollector: RollbarPLCrashCollector())

        // Note the ability to add aditional key/value pairs to the occurrence data for extra context
        Rollbar.infoMessage(
            "Rollbar is up and running! Enjoy your remote error and log monitoring...",
            data: ["key_x": "value_x", "key_y": "value_y"])

        return true
    }
}

extension Rollbar {
    /// `return true` means DO NOT send the data to Rollbar (i.e. ignore)
    /// `return false` means DO send the data to Rollbar
    static func shouldIgnore(payload: RollbarData) -> Bool {
        return false
    }

    /// Transform the occurrence payload just before the data is sent.
    ///
    /// This allows data to be added/removed from the payload basd on some
    /// aspect of the payload data.
    ///
    /// This method is often used to do advanced data scrubbing or to add
    /// additional data to the payload that is only available at the time
    /// the error occurs.
    static func transform(payload: RollbarData) -> RollbarData {
        // Context is an indexed fast search field in the Rollbar Web UI
        //
        // The items timeline view can be filtered by context
        // https://docs.rollbar.com/docs/search-items#context
        payload.context = "owner#ui_team"

        return payload
    }
}
