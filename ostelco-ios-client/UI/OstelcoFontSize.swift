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
    case inputHeadline
    case onboarding
    
    var toCGFloat: CGFloat {
        switch self {
        case .finePrint:
            return 12
        case .inputHeadline:
            return 13
        case .body:
            return 17
        case .onboarding:
            return 18
        case .dataDecimals,
             .heading2:
            return 28
        case .heading1:
            return 50
        case .data:
            return 84
        }
    }
}
