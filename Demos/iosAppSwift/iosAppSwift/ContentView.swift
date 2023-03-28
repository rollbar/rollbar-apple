import SwiftUI
import Foundation
import RollbarNotifier

enum ExampleError: Error {
    case
        invalidResult,
        invalidInput,
        someOtherError
}

struct ContentView: View {
    @AppStorage("rollbar_post_client_item_access_token") var accessToken = ""

    let example = Example()

    func button(_ title: String, action: @escaping () -> ()) -> some View {
        Button(title, action: action)
            .buttonStyle(.bordered)
            .tint(.blue)
    }

    func restartIfValid(_ accessToken: String) {
        guard accessToken.isValid else { return }

        let config = Rollbar.configuration().mutableCopy()
        config.destination.accessToken = accessToken
        Rollbar.update(withConfiguration: config)

        Rollbar.infoMessage("Rollbar Apple SDK access token changed.")

        print("Rollbar Apple SDK access token changed to \(accessToken)")
    }

    var body: some View {
        VStack {
            Text("Rollbar Apple SDK Demo")
                .font(.title)
                .padding(.bottom)

            TextField("post client item access token", text: $accessToken)
                .foregroundColor(accessToken.isValid ? .accentColor : .red)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.center)
                .textCase(.lowercase)
                .lineLimit(1)
                .onChange(of: accessToken, perform: restartIfValid)
                .padding(.bottom)

            ScrollView {
                VStack {
                    Group {
                        button("Log a message", action: example.logMessage)
                        button("Manual Logging Example", action: example.manualLogging)
                            .padding(.bottom)
                        button("Force unwrap nil") { example.forceUnwrapNil(Int?.none) }
                        button("Implicitly unwrapped nil") { example.implicitlyUnwrapped(nil) }
                            .padding(.bottom)
                    }

                    Group {
                        button("Force try! and fail") { try! example.throwError() }
                        button("Force as! invalid cast") { example.forceInvalidCast([""]) }
                        button("Unsafe bit cast") { example.unsafeBitCast(0) }
                            .padding(.bottom)

                        button("Out of bounds access") { example.outOfBounds(Int.max) }
                        button("Increment past endIndex") { example.incrementPastEndIndex(0...3) }
                        button("Outside UInt range") { example.outsideRepresentableRange(-21.5) }
                            .padding(.bottom)

                        button("Duplicate Dictionary keys") { example.duplicateKeys("someKey") }
                        button("Divide by zero") { example.divide(by: 0) }
                        button("Throw an NSException") { example.throwNSException((1, 2)) }
                        button("Fatal Error", action: example.forceFatalError)
                            .padding(.bottom)
                    }
                }.padding(.horizontal)
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Example {
    let logger = RollbarLogger(configuration: Rollbar.configuration())

    /// Log a single informational message to Rollbar.
    func logMessage() {
        Rollbar.infoMessage(
            "Rollbar is up and running! Enjoy your remote error and log monitoring...",
            data: ["key_x": "value_x", "key_y": "value_y"])
    }

    /// Some different ways to explicitly log an error to Rollbar.
    func manualLogging() {
        Rollbar.log(.error, message: "My log message")

        let extraInfo =  ["item_1": "value_1", "item_2": "value_2"]

        Rollbar.log(
            .error,
            error: ExampleError.invalidInput,
            data: extraInfo,
            context: "Some additional information.")

        Rollbar.errorMessage("My error message", data: extraInfo)

        Rollbar.criticalError(ExampleError.invalidResult, data: extraInfo)

        do {
            throw ExampleError.someOtherError
        } catch {
            Rollbar.errorError(error, data: extraInfo)
        }
    }

    /// A hard crash is captured by the crash reporter. The next time
    /// the application is started, the data is sent to Rollbar.
    func forceFatalError() {
        fatalError("This is the description of a fatal error.")
    }

    func forceUnwrapNil<T: Numeric>(_ x: T?) {
        // implementation detail:
        // ----------------------
        // since these functions are basically no-ops, the
        // optimizer is clever enough to crush all of them
        // into a single no-op, which in turn, messes up the
        // stackframe.
        //
        // we prevent this by simply producing a side-effect.
        //
        // all other functions follow the same pattern:
        //  1. a side-effect (print), followed by
        //  2. an illegal operation that crashes the app.
        print("forceUnwrapNil: \(String(describing: x))") // the side-effect.

        _ = x! * x! // the illegal op.
    }

    func implicitlyUnwrapped(_ s: String!) {
        print("implicitlyUnwrappedArgument: \(String(describing: s))")
        _ = s.lowercased()
    }

    func forceInvalidCast<T>(_ xs: [T]) {
        print("forceInvalidCast: \(xs)")
        _ = xs as! [Double]
    }

    func unsafeBitCast(_ x: Float) {
        print("unsafeBitCast: \(x)")
        _ = Swift.unsafeBitCast(x, to: String.self)
    }

    func outOfBounds(_ index: Int) {
        print("outOfBounds: \(index)")
        _ = [][index]
    }

    func incrementPastEndIndex(_ r: ClosedRange<Int>) {
        print("incrementPastEndIndex: \(r)")
        _ = r.index(after: r.endIndex)
    }

    func outsideRepresentableRange(_ d: Double) {
        print("outsideRepresentableRange: \(d)")
        _ = UInt(d)
    }

    func duplicateKeys(_ key: String) {
        print("duplicateKeys: \(key)")
        var map = [key: 1, key: 1] // the illegal op.
        // implementation detail:
        // this function requires a bit more effectful trickery to
        // prevent the optimizer from simply removing the line above.
        if let x = map[key] {
            map[key] = x + x
        }
    }

    func divide(by y: Int) {
        print("divideBy: \(y)")
        _ = 1 / y
    }

    func throwError() throws {
        print("throwError: ExampleError.someOtherError")
        throw ExampleError.someOtherError
    }

    func throwNSException<A, B>(_ pair: (A, B)) {
        print("throwNSException: \(pair)")
        _ = try? JSONSerialization.data(withJSONObject: pair)
    }
}
