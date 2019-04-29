//
//  ValidationState.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/29/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

enum ValidationState {
    case notChecked
    case valid
    case error(description: String)
}

extension ValidationState: Equatable {
    
    static func == (lhs: ValidationState, rhs: ValidationState) -> Bool {
        switch (lhs, rhs) {
        case (.notChecked, .notChecked):
            return true
        case (.valid, .valid):
            return true
        case (.error(let error1), .error(let error2)):
            return error1 == error2
        default:
            return false
        }
    }
}
