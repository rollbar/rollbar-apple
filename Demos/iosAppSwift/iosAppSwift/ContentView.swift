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

    var body: some View {
        VStack {
            Text("Rollbar Apple SDK Example")
                .font(.title)
                .padding(.bottom)

            VStack {
                Button("Manual Logging Example", action: example.manualLogging)
                    .tint(.blue)
                    .buttonStyle(.bordered)

                Button("Divide by zero") { _ = example.divide(by: 0) }
                    .tint(.blue)
                    .buttonStyle(.bordered)

                Button("Log invalid JSON", action: example.logInvalidJson)
                    .tint(.blue)
                    .buttonStyle(.bordered)
                    .padding(.bottom)

                Button("Throw an ExampleError") { try! example.throwError() }
                    .tint(.blue)
                    .buttonStyle(.bordered)

                Button("Throw an NSException", action: example.throwNSException)
                    .tint(.blue)
                    .buttonStyle(.bordered)
                    .padding(.bottom)

                Button("Assertion Failure", action: example.forceAssertionFailure)
                    .tint(.blue)
                    .buttonStyle(.bordered)

                Button("Precondition Failure", action: example.forcePreconditionFailure)
                    .tint(.blue)
                    .buttonStyle(.bordered)

                Button("Fatal Error", action: example.forceFatalError)
                    .tint(.blue)
                    .buttonStyle(.bordered)
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

    func forcePreconditionFailure() {
        preconditionFailure("Precondition failed")
    }

    func forceAssertionFailure() {
        assertionFailure("Assertion failed")
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

    func logInvalidJson() {
        Rollbar.log(
            .warning,
            message: "Logging with extras and context",
            data: [
                "fingerprint": "targeted-mistake-recycling-incorrect-range",
                "bestSolutionTokens": [51241, 42421, 32142],
                "guessTokens": [22414, 89389],
                // This is a (Int, Int), which can't be turned into Json
                "detectedRangeStart": (1, 10),
            ],
            context: "Rollbar Example Logging Invalid Json")
    }
}
