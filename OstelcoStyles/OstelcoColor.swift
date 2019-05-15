//
//  OstelcoColor.swift
//  OstelcoStyles
//
//  Created by Ellen Shapiro on 4/23/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

/// Colors from https://app.zeplin.io/project/5c8b989f46989524fb0258ac/styleguide
public enum OstelcoColor: CaseIterable {
    case aquamarine
    case black
    case blackForText
    case darkGrey
    case greyedOut
    case orangeYellow
    case oyaBlue
    case paleGrey
    case watermelon
    case white
    
    public static var useDevColor = false
    
    public var toUIColor: UIColor {
        switch self {
        case .aquamarine:
            return .from(red: 0, green: 206, blue: 181)
        case .black:
            return .from(red: 0, green: 0, blue: 0)
        case .blackForText:
            return .from(red: 45, green: 45, blue: 45)
        case .darkGrey:
            return .from(red: 110, green: 110, blue: 110)
        case .greyedOut:
            return .from(red: 161, green: 161, blue: 161)
        case .orangeYellow:
            return .from(red: 255, green: 168, blue: 0)
        case .oyaBlue:
            if OstelcoColor.useDevColor {
                return .from(red: 0, green: 186, blue: 203)
            } else {
                return .from(red: 47, green: 22, blue: 232)
            }
        case .paleGrey:
            return .from(red: 221, green: 221, blue: 229)
        case .watermelon:
            return .from(red: 255, green: 56, blue: 125)
        case .white:
            return .from(red: 255, green: 255, blue: 255)
        }
    }
    
    var toPixelImage: UIImage {
        return self.toUIColor.toPixelImage
    }
}

private extension UIColor {
    
    static func from(red: Int, green: Int, blue: Int) -> UIColor {
        return UIColor(red: CGFloat(red) / 255.0,
                       green: CGFloat(green) / 255.0,
                       blue: CGFloat(blue) / 255.0,
                       alpha: 1)
    }
}
