//
//  OstelcoFont.swift
//  OstelcoStyles
//
//  Created by Ellen Shapiro on 4/23/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

/// The combination of a font type and size which makes a font.
public class OstelcoFont {
    public let fontType: OstelcoFontType
    public let fontSize: OstelcoFontSize
    
    public init(fontType: OstelcoFontType,
                fontSize: OstelcoFontSize) {
        self.fontType = fontType
        self.fontSize = fontSize
    }
    
    public var toUIFont: UIFont {
        return UIFont.systemFont(ofSize: self.fontSize.toCGFloat, weight: self.fontType.fontWeight)
    }
    
    public static var bodyText = OstelcoFont(fontType: .regular, fontSize: .body)
}

/// The types of font as indicated in https://app.zeplin.io/project/5c8b989f46989524fb0258ac/styleguide
public enum OstelcoFontType: CaseIterable {
    case bold
    case medium
    case regular
    
    var fontWeight: UIFont.Weight {
        switch self {
        case .bold:
            return .bold
        case .medium:
            return .medium
        case .regular:
            return .regular
        }
    }
}
