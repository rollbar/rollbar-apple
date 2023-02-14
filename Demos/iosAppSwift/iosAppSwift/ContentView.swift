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
    let example = Example()

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

                Group {
                    button("Force unwrap nil", action: example.forceUnwrapNil)
                    button("Implicitly unwrapped nil argument") { example.implicitlyUnwrappedArgument(nil) }
                    button("Implicitly unwrapped nil value", action: example.implicitlyUnwrappedValue)
                        .padding(.bottom)
                }

                Group {
                    button("Force as! invalid cast") { example.forceInvalidCast(to: Int.self) }
                    button("Unsafe bit cast", action: example.unsafeBitCast)
                        .padding(.bottom)
                }

                Group {
                    button("Out of bounds access", action: example.outOfBounds)
                    //button("Increment past endIndex", action: example.incrementPastEndIndex)
                    //button("Neg Double outside UInt range") { example.outsideRepresentableRange(-21.5) }
                    button("Duplicate Dictionary keys", action: example.duplicateKeys)
                    button("Divide by zero") { example.divide(by: 0) }
                        .padding(.bottom)
                }

                Group {
                    button("Force try! and fail") { try! example.throwError() }
                    button("Throw an NSException", action: example.throwNSException)
                        .padding(.bottom)
                }

                Group {
                    button("Assertion Failure", action: example.forceAssertFailure)
                    button("Precondition Failure", action: example.forcePrecondFailure)
                    button("Fatal Error", action: example.forceFatalError)
                }
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

        Rollbar.criticalError(ExampleError.invalidResult, data: extraInfo)

        do {
            throw ExampleError.outOfBounds
        } catch {
            Rollbar.errorError(error, data: extraInfo)
        }
    }

    /// A hard crash is captured by the crash reporter. The next time
    /// the application is started, the data is sent to Rollbar.
    func forceFatalError() {
        fatalError("This is the description of a fatal error.")
    }

    func forcePrecondFailure() {
        preconditionFailure("The description of a precondition failure")
    }

    func forceAssertFailure() {
        assertionFailure("The description of an assertion failure")
    }

    func forceUnwrapNil() {
        _ = String?.none!
    }

    func implicitlyUnwrappedArgument(_ x: Int!) {
        _ = x + 1
    }

    func implicitlyUnwrappedValue() {
        let x: Int! = nil
        _ = x + 1
    }

    func forceInvalidCast<T>(to type: T.Type) {
        _ = "" as! T
    }

    func outsideRepresentableRange(_ d: Double) {
        _ = UInt(d)
    }

    func outOfBounds() {
        _ = [][Int.max]
    }

    func duplicateKeys() {
        _ = ["one": 1, "one": 1]
    }

    func incrementPastEndIndex() {
        let r = 0...3
        _ = r.index(after: r.endIndex)
    }

    func unsafeBitCast() {
        _ = Swift.unsafeBitCast(Int.min, to: String.self)
    }

    func divide(by y: Int) {
        _ = 1 / y
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
