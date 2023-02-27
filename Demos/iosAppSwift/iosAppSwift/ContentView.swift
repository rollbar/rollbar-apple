import SwiftUI
import Foundation
import RollbarSwift
import RollbarNotifier

enum ExampleError: Error {
    case
        invalidResult,
        invalidInput,
        someOtherError
}

struct ContentView: View {
    let example = Example()

    func button(_ title: String, action: @escaping () -> ()) -> some View {
        return Button(title, action: action)
            .buttonStyle(.bordered)
            .tint(.blue)
    }

    var body: some View {
        VStack {
            Text("Rollbar Apple SDK Example")
                .font(.title)
                .padding(.bottom)

            VStack {
                Group {
                    button("Manual Logging Example", action: example.manualLogging)
                        .padding(.bottom)
                }

                Group {
                    button("Fatal Error", action: example.forceFatalError)
                        .padding(.bottom)
                }

                Group {
                    button("Force unwrap nil") { example.forceUnwrapNil(Int?.none) }
                    button("Implicitly unwrapped nil arg") { example.implicitlyUnwrappedArg(String?.none) }
                        .padding(.bottom)
                }

                Group {
                    button("Force as! invalid cast") { example.forceInvalidCast([""]) }
                    button("Unsafe bit cast") { example.unsafeBitCast(0) }
                        .padding(.bottom)
                }

                Group {
                    button("Out of bounds access") { example.outOfBounds(Int.max) }
                    button("Increment past endIndex") { example.incrementPastEndIndex(0...3) }
                    button("Outside UInt range") { example.outsideRepresentableRange(-21.5) }
                    button("Duplicate Dictionary keys") { example.duplicateKeys("someKey") }
                    button("Divide by zero") { example.divide(by: 0) }
                        .padding(.bottom)
                }

                Group {
                    button("Force try! and fail") { try! example.throwError() }
                    button("Throw an NSException") { example.throwNSException((1, 2)) }
                        .padding(.bottom)
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
        // since these functions are basically noops, the
        // optimizer is clever enough to crush all of them
        // into a single noop, which in turn, messes up the
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

    func implicitlyUnwrappedArg<S: StringProtocol>(_ s: S!) {
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
        // this function requires a bit more trickery to prevent
        // the optimizer from simply removing the line above.
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
