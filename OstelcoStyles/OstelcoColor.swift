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
    case background
    case controlTint
    case disabled
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
    case statusError
    case statusGood
    case statusOkay
    case stepItemBulletLocked
    case stepItemBulletUnlocked
    case stepItemLabel
    case stepItemLabelActive
    case text
    case textBalance
    case textHeading
    case textLink
    case textSecondary
    
    public var toUIColor: UIColor {
        let bundle = Bundle(for: OstelcoButton.classForCoder())
        if let bundleIndentifier = Bundle.main.bundleIdentifier, bundleIndentifier.contains("dev") {
            return UIColor(named: "oyaBlue-dev", in: bundle, compatibleWith: nil)!
        }
        return UIColor(named: self.rawValue, in: bundle, compatibleWith: nil)!
    }
    
    var toPixelImage: UIImage {
        return self.toUIColor.toPixelImage
    }
}
