//
//  File.swift
//  
//
//  Created by Andrey Kornich on 2020-06-01.
//

import Foundation
import RollbarCommon

@objc public class RollbarTestUtil: NSObject {
    
    private static let payloadsStore = "rollbar.db";
        
    private static let incomingPayloadsLog = "rollbar.incoming";
    private static let transmittedPayloadsLog = "rollbar.transmitted";
    private static let droppedPayloadsLog = "rollbar.dropped";

    private static let telemetryFileName = "rollbar.telemetry";

    private static func getPayloadsStoreFilePath() -> String {
        let cachesDirectory = RollbarCachesDirectory.directory() ;
        let filePath = URL(fileURLWithPath: cachesDirectory).appendingPathComponent(payloadsStore);
        return filePath.path;
    }
    
    private static func getIncomingPayloadsLogFilePath() -> String {
        let cachesDirectory = RollbarCachesDirectory.directory() ;
        let filePath = URL(fileURLWithPath: cachesDirectory).appendingPathComponent(incomingPayloadsLog);
        return filePath.path;
    }

    private static func getTransmittedPayloadsLogFilePath() -> String {
        let cachesDirectory = RollbarCachesDirectory.directory() ;
        let filePath = URL(fileURLWithPath: cachesDirectory).appendingPathComponent(transmittedPayloadsLog);
        return filePath.path;
    }
    
    private static func getDroppedPayloadsLogFilePath() -> String {
        let cachesDirectory = RollbarCachesDirectory.directory() ;
        let filePath = URL(fileURLWithPath: cachesDirectory).appendingPathComponent(droppedPayloadsLog);
        return filePath.path;
    }
    
    private static func getTelemetryFilePath() -> String {
        let cachesDirectory = RollbarCachesDirectory.directory() ;
        let filePath = URL(fileURLWithPath: cachesDirectory).appendingPathComponent(telemetryFileName);
        return filePath.path;
    }

    @objc public static func checkFileExists(filePath:String!) -> Bool {
        if ((filePath == nil) || filePath.isEmpty) {
            return false;
        }
        let fileManager = FileManager.default;
        let fileExists = fileManager.fileExists(atPath: filePath);
        return fileExists;
    }

    @objc public static func deleteFile(filePath:String!) {
        if ((filePath == nil) || filePath.isEmpty) {
            return;
        }
        let fileManager = FileManager.default;
        let fileExists = fileManager.fileExists(atPath: filePath);
        if fileExists {
            do {
                try fileManager.removeItem(atPath: filePath);
            } catch {
                print("Unexpected error: \(error).")
            }
        }
    }

    @objc public static func clearFile(filePath:String!) {
        if ((filePath == nil) || filePath.isEmpty) {
            return;
        }
        let fileManager = FileManager.default;
        let fileExists = fileManager.fileExists(atPath: filePath);
        if fileExists {
            RollbarTestUtil.deleteFile(filePath: filePath);
            fileManager.createFile(atPath: filePath, contents: nil, attributes: nil);
        }
    }

    @objc public static func checkPayloadsStoreFileExists() -> Bool {
        let filePath = RollbarTestUtil.getPayloadsStoreFilePath();
        return RollbarTestUtil.checkFileExists(filePath: filePath);
    }

    @objc public static func deletePayloadsStoreFile() {
        let filePath = RollbarTestUtil.getPayloadsStoreFilePath();
        RollbarTestUtil.deleteFile(filePath: filePath);
    }
    
    @objc public static func clearTelemetryFile() {
        let filePath = RollbarTestUtil.getTelemetryFilePath();
        RollbarTestUtil.clearFile(filePath: filePath);
    }

    @objc public static func deleteLogFiles() {
        
        let logs : [String] = [
            RollbarTestUtil.getIncomingPayloadsLogFilePath(),
            RollbarTestUtil.getTransmittedPayloadsLogFilePath(),
            RollbarTestUtil.getDroppedPayloadsLogFilePath(),
        ];
        
        let fileManager = FileManager.default;
        
        for log in logs {
            if fileManager.fileExists(atPath: log) {
                RollbarTestUtil.deleteFile(filePath: log);
            }
        }
    }
    
    @objc public static func readFirstIncomingPayloadAsString() -> String? {
        
        return RollbarTestUtil.readFirstItemStringFromLogFile(filePath: RollbarTestUtil.getIncomingPayloadsLogFilePath());
    }
    
    @objc public static func readFirstTransmittedPayloadAsString() -> String? {
        
        return RollbarTestUtil.readFirstItemStringFromLogFile(filePath: RollbarTestUtil.getTransmittedPayloadsLogFilePath());
    }
    
    @objc public static func readFirstDroppedPayloadAsString() -> String? {
        
        return RollbarTestUtil.readFirstItemStringFromLogFile(filePath: RollbarTestUtil.getDroppedPayloadsLogFilePath());
    }

    @objc public static func readFirstItemStringFromLogFile(filePath: String) -> String? {
        
        let fileReader = RollbarFileReader(filePath: filePath, andOffset: 0);
        let item = fileReader.readLine();
        return item;
    }

    @objc public static func readIncomingPayloadsAsStrings() -> [String] {
        
        return RollbarTestUtil.readItemStringsFromLogFile(filePath: RollbarTestUtil.getIncomingPayloadsLogFilePath());
    }

    @objc public static func readTransmittedPayloadsAsStrings() -> [String] {
        
        return RollbarTestUtil.readItemStringsFromLogFile(filePath: RollbarTestUtil.getTransmittedPayloadsLogFilePath());
    }
    
    @objc public static func readDroppedPayloadsAsStrings() -> [String] {
        
        return RollbarTestUtil.readItemStringsFromLogFile(filePath: RollbarTestUtil.getDroppedPayloadsLogFilePath());
    }
    
    @objc public static func readItemStringsFromLogFile(filePath: String) -> [String] {
        
        let fileReader = RollbarFileReader(filePath: filePath, andOffset: 0);
        var items = [String]();
        fileReader.enumerateLines({ (line, nextOffset, stop) in
            if (line == nil) {
                return;
            }
            items.append(line!);
        });
        return items;
    }

    @objc public static func readIncomingPayloads() -> [NSMutableDictionary] {
        
        return RollbarTestUtil.readItemsFromLogFile(filePath: RollbarTestUtil.getIncomingPayloadsLogFilePath());
    }
    
    @objc public static func readTransmittedPayloads() -> [NSMutableDictionary] {
        
        return RollbarTestUtil.readItemsFromLogFile(filePath: RollbarTestUtil.getTransmittedPayloadsLogFilePath());
    }
    
    @objc public static func readDroppedPayloads() -> [NSMutableDictionary] {
        
        return RollbarTestUtil.readItemsFromLogFile(filePath: RollbarTestUtil.getDroppedPayloadsLogFilePath());
    }
    
    @objc public static func readItemsFromLogFile(filePath: String) -> [NSMutableDictionary] {

        let fileReader = RollbarFileReader(filePath: filePath, andOffset: 0);
        var items = [NSMutableDictionary] ();
        fileReader.enumerateLines({ (line, nextOffset, stop) in
            if (line == nil) {
                return;
            }
            var payload : NSMutableDictionary? = nil;
            do {
                try payload = JSONSerialization.jsonObject(
                    with: (line?.data(using: .utf8))!,
                    options: [.mutableContainers, .mutableLeaves]
                    ) as? NSMutableDictionary;
            } catch {
                print("Unexpected error: \(error).")
            }
            if payload == nil {
                return;
            }
            items.append(payload!["data"] as! NSMutableDictionary);
        });
        
        return items;
    }
    
    @objc public static func wait(waitTimeInSeconds: TimeInterval = 2.0) {
        Thread.sleep(forTimeInterval: waitTimeInSeconds);
    }

    public static func simulateError(callDepth: inout uint) throws {
        callDepth = callDepth - 1;
        if (callDepth > 0) {
            try RollbarTestUtil.simulateError(callDepth: &callDepth);
        }
        else {
            throw RollbarTestUtilError.simulatedException(errorDescription: "An error was just simulated!");
        }
    }
    
    @objc public static func makeTroubledCall() throws {
        try makeInnerTroubledCall();
    }

    private static func makeInnerTroubledCall() throws {
        try makeMostInnerTroubledCall();
    }

    private static func makeMostInnerTroubledCall() throws {
        //throw RollbarTestUtilError.basicError;
        //throw RollbarTestUtilError.simulatedException(errorDescription: "ENUM ERROR: Trouble at its source!");
        //throw BackTracedError(errorDescription: "BACKTRACED ERROR: Trouble at its source!");
        throw CustomError(errorDescription: "CUSTOM BACKTRACED ERROR: Trouble at its source!");
        //throw CustomError();
    }

//    public static func flushFileThread(logger: RollbarLogger) {
//        logger.perform(
//            #selector(logger._test_do_nothing),
//            on: logger._rollbarThread,
//            with: nil,
//            waitUntilDone: true
//        );
//
////        [notifier performSelector:@selector(_test_doNothing)
////                         onThread:[notifier _rollbarThread] withObject:nil waitUntilDone:YES];
//    }
    
}

public enum RollbarTestUtilError: Error {
    case basicError
    case simulatedError(errorDescription: String)
    case simulatedException(errorDescription: String, errorCallStack: [String] = Thread.callStackSymbols)
    //case nullReferenceException = RollbarErrorBase("Null reference!")
    
}

public protocol BackTracedErrorProtocol : Error /*OR LocalizedError OR CustomNSError*/ {
    var errorDescription: String { get }
    var errorCallStack: [String] { get }
}

struct BackTracedError : BackTracedErrorProtocol {
    
    private let _errorDescription: String;
    private let _errorCallStack: [String];
    
    init(errorDescription: String, errorCallStack: [String] = Thread.callStackSymbols) {
        self._errorDescription = errorDescription;
        self._errorCallStack = errorCallStack;
    }
    
    var errorDescription: String {
        return self._errorDescription;
    }
    
    var errorCallStack: [String] {
        return self._errorCallStack;
    }
}

class BackTracedErrorBase: BackTracedErrorProtocol {
    
    private let _errorDescription: String;
    private let _errorCallStack: [String];
    
    init(errorDescription: String, errorCallStack: [String] = Thread.callStackSymbols) {
        self._errorDescription = errorDescription;
        self._errorCallStack = errorCallStack;
    }
    
    var errorDescription: String {
        return self._errorDescription;
    }

    var errorCallStack: [String] {
        return self._errorCallStack;
    }
}

class CustomError: BackTracedErrorBase {
    
    convenience init() {
        self.init(errorDescription: "Default back-traced error!");
    }
    
    init(errorDescription: String) {
        super.init(errorDescription: errorDescription);
    }
}
