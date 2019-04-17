//
//  Theme.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/8/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

enum Theme: Int {
    case BlueTheme
    case TurquoiseTheme
    
    var mainColor: UIColor {
        switch self {
        case .BlueTheme:
            return UIColor(named: "PeacockBlue")!
        case .TurquoiseTheme:
            return UIColor(named: "TurquoiseBlue")!
        }
    }
    
    var textOnMainColor: UIColor {
        return UIColor(named: "White")!
    }
    
    // swiftlint:disable discouraged_object_literal
    // (we're gonna fix this with codegen later)
    var logo: UIImage {
        switch self {
        case .BlueTheme:
            return #imageLiteral(resourceName: "StoryboardLaunchScreenProduction")
        case .TurquoiseTheme:
            return #imageLiteral(resourceName: "StoryboardLaunchScreenDevelopment")
        }
    }
    
    var splash: UIImage {
        switch self {
        case .BlueTheme:
            return #imageLiteral(resourceName: "StoryboardLaunchScreenProduction")
        case .TurquoiseTheme:
            return #imageLiteral(resourceName: "StoryboardLaunchScreenDevelopment")
        }
    }
    // swiftlint:enable discouraged_object_literal
}
