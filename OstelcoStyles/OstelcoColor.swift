//
//  OstelcoColor.swift
//  OstelcoStyles
//
//  Created by Ellen Shapiro on 4/23/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

/// Colors from https://app.zeplin.io/project/5c8b989f46989524fb0258ac/styleguide
public enum OstelcoColor: String, CaseIterable {
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
        let bundle = Bundle(for: OstelcoButton.classForCoder())
        if OstelcoColor.useDevColor, case .oyaBlue = self {
            return UIColor(named: "oyaBlue-dev", in: bundle, compatibleWith: nil)!
        }
        return UIColor(named: self.rawValue, in: bundle, compatibleWith: nil)!
    }
    
    var toPixelImage: UIImage {
        return self.toUIColor.toPixelImage
    }
}
