//
//  OstelcoColor.swift
//  OstelcoStyles
//
//  Created by Ellen Shapiro on 4/23/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import SwiftUI

/// Colors from https://app.zeplin.io/project/5c8b989f46989524fb0258ac/styleguide
public enum OstelcoColor: String, CaseIterable {
    case azul
    case background
    case backgroundLight
    case blackForText
    case containerBorder
    case controlTint
    case countryText
    case countryTextSecondary
    case disabled
    case highlighted
    case lipstick
    case inputBackground
    case inputLabel
    case inputPlaceholder
    case oyaBlue
    case paginationActive
    case paginationInactive
    case primaryButtonBackground
    case primaryButtonBackgroundDisabled
    case primaryButtonLabel
    case primaryButtonLabelDisabled
    case regionShadow
    case secondaryButtonLabel
    case shadow
    case statusError
    case statusGood
    case statusOkay
    case stepItemBulletLocked
    case stepItemBulletUnlocked
    case text
    case textBalance
    case textHeading
    case textLink
    case textSecondary
    
    public var toUIColor: UIColor {
        let bundle = Bundle(for: OstelcoButton.classForCoder())
        if let bundleIndentifier = Bundle.main.bundleIdentifier, bundleIndentifier.contains("dev"), case .oyaBlue = self {
            return UIColor(named: "oyaBlue-dev", in: bundle, compatibleWith: nil)!
        }
        return UIColor(named: self.rawValue, in: bundle, compatibleWith: nil)!
    }
    
    public var toColor: Color {
        return Color(self.toUIColor)
    }
    
    var toPixelImage: UIImage {
        return self.toUIColor.toPixelImage
    }
}
