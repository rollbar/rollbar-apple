import SwiftUI
import RollbarSwift
import RollbarNotifier

enum ExampleError: Error {
    case
        invalidResult,
        outOfBounds,
        invalidInput
}

struct ContentView: View {
    let example = Example();

    func button(_ title: String, action: @escaping () -> ()) -> some View {
        Button(title, action: action)
            .buttonStyle(.bordered)
            .tint(.blue)
    }

    var body: some View {
        VStack {
            Text("Rollbar Apple SDK Example")
                .font(.title)
                .padding(.bottom)

            VStack {
                button("Manual Logging Example", action: example.manualLogging)
                    .padding(.bottom)
                button("Force unwrap nil", action: example.forceUnwrapNil)
                button("Force invalid cast") { example.forceInvalidCast(to: Int.self) }
                button("Force try and fail") { try! example.throwError() }
                button("Out of bounds access", action: example.outOfBounds)
                button("Divide by zero") { _ = example.divide(by: 0) }
                button("Throw an NSException", action: example.throwNSException)
                    .padding(.bottom)
                button("Assertion Failure", action: example.forceAssertFailure)
                button("Precondition Failure", action: example.forcePrecondFailure)
                button("Fatal Error", action: example.forceFatalError)
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

    /// Some different ways to explicitly log an error to Rollbar.
    func manualLogging() {
        let extraInfo =  ["item_1": "value_1", "item_2": "value_2"]

        Rollbar.log(.error, message: "My log message")

        Rollbar.log(
            .error,
            error: ExampleError.invalidInput,
            data: extraInfo,
            context: "Some additional information.")

        Rollbar.errorMessage("My error message", data: extraInfo)

        Rollbar.errorError(ExampleError.invalidResult, data: extraInfo)

        do {
            throw ExampleError.outOfBounds
        } catch {
            Rollbar.errorError(error, data: extraInfo)
        }
    }

    /// A hard crash is captured by the crash reporter. The next time
    /// the application is started, the data is sent to Rollbar.
    func forceFatalError() {
        fatalError("Force a crash")
    }

    func forcePrecondFailure() {
        preconditionFailure("Precondition failed")
    }

    func forceAssertFailure() {
        assertionFailure("Assertion failed")
    }

    func forceUnwrapNil() {
        let x = Optional<String>.none
        let _ = x!
    }

    func forceInvalidCast<T>(to type: T.Type) {
        let x = ""
        let _ = x as! T
    }

    func outOfBounds() {
        let _ = [][Int.max]
    }

    func divide(by y: Int) -> Int {
        1 / y
    }

    func throwError() throws {
        throw ExampleError.outOfBounds
    }

    func throwNSException() {
        RollbarExceptionGuard(logger: logger).tryExecute {
            RollbarTryCatch.throw("NSException from ObjC")
        }
    }
}
