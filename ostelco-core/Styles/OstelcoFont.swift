//
//  OstelcoFont.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 4/23/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

public struct OstelcoFont {
    public let fontType: OstelcoFontType
    public let fontSize: OstelcoFontSize
    
    var toUIFont: UIFont {
        guard let font = UIFont(name: self.fontType.fontName, size: self.fontSize.toCGFloat) else {
            fatalError("Couldn't find font named \(self.fontType.fontName)")
        }
        
        return font
    }
    
    public static var bodyText = OstelcoFont(fontType: .regular, fontSize: .body)
}

public enum OstelcoFontType: CaseIterable {
    case alternateBold
    case bold
    case heavy
    case medium
    case regular
    
    var fontName: String {
        switch self {
        case .alternateBold:
            return "Telenor"
        case .bold:
            return "SFProText-Bold"
        case .heavy:
            return "SFProText-Heavy"
        case .medium:
            return "SFProText-Medium"
        case .regular:
            return "SFProText-Regular"
        }
    }
}

public enum OstelcoFontSize: CaseIterable {
    case body
    case data
    case dataDecimals
    case finePrint
    case heading1
    case heading2
    case onboarding
    case secondary

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
        }
    }
}
