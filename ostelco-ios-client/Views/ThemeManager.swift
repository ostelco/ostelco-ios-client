//
//  ThemeManager.swift
//  ostelco-ios-client
//
//  Created by mac on 11/6/18.
//  Copyright © 2018 mac. All rights reserved.
//
// Heavly insipred from https://medium.com/@abhimuralidharan/maintaining-a-colour-theme-manager-on-ios-swift-178b8a6a92

import UIKit
import Foundation

enum Theme: Int {
    case BlueTheme, TurquoiseTheme
    
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
}

// Enum declaration
let SelectedThemeKey = "SelectedTheme"

// This will let you use a theme in the app.
class ThemeManager {
    
    // ThemeManager
    static func currentTheme() -> Theme {
        if let storedTheme = (UserDefaults.standard.value(forKey: SelectedThemeKey) as AnyObject).integerValue {
            return Theme(rawValue: storedTheme)!
        } else {
            return .TurquoiseTheme
        }
    }
    
    static func applyTheme(theme: Theme) {
        // First persist the selected theme using NSUserDefaults.
        UserDefaults.standard.setValue(theme.rawValue, forKey: SelectedThemeKey)
        UserDefaults.standard.synchronize()
        
        
        UITabBar.appearance().tintColor = theme.mainColor
        UIToolbar.appearance().tintColor = theme.mainColor
        UINavigationBar.appearance().tintColor = theme.mainColor
    }
}
