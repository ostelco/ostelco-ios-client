//
//  AppErrors.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 30/04/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import Crashlytics
import Foundation
import ostelco_core

/// Wrapper for logging errors throughout the application
struct ApplicationErrors {
    enum General: LocalizedError {
        case assertionFailed(message: String, file: String, line: UInt)
        case couldntConvertUserInfoToNotificaitonData(userInfo: [AnyHashable: Any]?)
        case noValidPlansFound
        case noMyInfoConfigFound

        var localizedDescription: String {
            switch self {
            case .assertionFailed(let message, let file, let line):
                return "Assertion failed in \(file) line \(line):\n\(message)"
            case .couldntConvertUserInfoToNotificaitonData(let userInfo):
                if let userInfo = userInfo {
                    return "Could not turn user info into a push notification: \(userInfo)"
                } else {
                    return "No user info received with a push notification!"
                }
            case .noValidPlansFound:
                return "Did not find a valid subscription plan"
            case .noMyInfoConfigFound:
                return "Did not find valid configuration for MyInfo"
            }
        }
    }
    
    /// Logs the passed-in error to our error logging software of choice and `debugPrint`s it
    /// (Currently: Crashlytics)
    ///
    /// - Parameters:
    ///   - error: The error to log
    ///   - userInfo: A dictionary with any additional user info to pass along. Defaults to nil.
    ///   - file: The file where this method was called. Defaults to the direct caller.
    ///   - line: The line where this method was called. Defaults to the direct caller.
    static func log(_ error: Error,
                    withAdditionalUserInfo userInfo: [String: Any]? = nil,
                    file: StaticString = #file,
                    line: UInt = #line) {
        debugPrint("""
            \(file.fileName) line \(line)
            - Error: \(error)
            - UserInfo: \(String(describing: userInfo))
            """)
        Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: userInfo)
    }
    
    /// Throws an assertion failure at the point where it's called in non-production builds.
    ///
    /// - Parameters:
    ///   - error: Any error conforming to `LocalizedError`
    ///   - file: The file where this method was called. Defaults to the direct caller.
    ///   - line: The line where this method was called. Defaults to the direct caller.
    static func assertAndLog(_ error: LocalizedError,
                             file: StaticString = #file,
                             line: UInt = #line) {
        assertionFailure(error.localizedDescription, file: file, line: line)
        self.log(error, file: file, line: line)
    }
    
    /// Throws an assertion failure at the point where it's called in non-production builds.
    /// Logs a non-fatal error in production builds.
    ///
    /// - Parameters:
    ///   - message: The message to include with the assertion failure
    ///   - file: The file where this method was called. Defaults to the direct caller.
    ///   - line: The line where this method was called. Defaults to the direct caller.
    static func assertAndLog(_ message: String,
                             file: StaticString = #file,
                             line: UInt = #line) {
        assertionFailure(message, file: file, line: line)
        let error = General.assertionFailed(message: message,
                                            file: file.fileName,
                                            line: line)
        Crashlytics.sharedInstance().recordError(error)
    }
}

fileprivate extension StaticString {
    
    var fileName: String {
        return (String(staticString: self) as NSString).lastPathComponent
    }
}
