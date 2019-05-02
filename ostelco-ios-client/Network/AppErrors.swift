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
        case noValidPlansFound

        var localizedDescription: String {
            switch self {
            case .noValidPlansFound:
                return "Did not find a valid subscription plan"
            }
        }
    }
    
    /// Logs the passed-in error to our error logging software of choice and `debugPrint`s it
    /// (Currently: Crashlytics)
    ///
    /// - Parameters:
    ///   - error: The error to log
    ///   - userInfo: A dictionary with any additional user info to pass along. Defaults to nil.
    static func log(_ error: Error,
                    withAdditionalUserInfo userInfo: [String : Any]? = nil,
                    file: StaticString = #file,
                    line: UInt = #line) {
        let fileName = (String(staticString: file) as NSString).lastPathComponent
        debugPrint("\(fileName) line \(line)\n- Error: \(error)\n- UserInfo: \(String(describing: userInfo))\n\n")
        Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: userInfo)
    }
}
