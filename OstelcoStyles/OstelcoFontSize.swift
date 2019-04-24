//
//  OstelcoFontSize.swift
//  OstelcoStyles
//
//  Created by Ellen Shapiro on 4/23/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

public enum OstelcoFontSize: CaseIterable {
    case body
    case data
    case dataDecimals
    case finePrint
    case heading1
    case heading2
    case onboarding
    case secondary
    case smallButton
    
    var toCGFloat: CGFloat {
        switch self {
        case .body:
            return 17
        case .data:
            return 84
        case .dataDecimals:
            return 28
        case .finePrint:
            return 12
        case .heading1:
            return 50
        case .heading2:
            return 32
        case .onboarding:
            return 18
        case .secondary:
            return 16
        case .smallButton:
            return 14
        }
    }
}
