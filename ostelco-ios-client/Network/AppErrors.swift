//
//  AppErrors.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 30/04/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import Crashlytics

class ApplicationErrors {
    enum General: LocalizedError {
        case noValidPlansFound

        var localizedDescription: String {
            switch self {
            case .noValidPlansFound:
                return "Did not find a valid subscription plan"
            }
        }
    }
    static func log(_ error: Error) {
        Crashlytics.sharedInstance().recordError(error)
    }
}
