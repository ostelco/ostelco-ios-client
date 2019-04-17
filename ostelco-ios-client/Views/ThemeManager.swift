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

// This will let you use a theme in the app.
class ThemeManager {
    
    // ThemeManager
    static func currentTheme() -> Theme {
        return UserDefaultsWrapper.storedTheme ?? .TurquoiseTheme
    }
    
    static func applyTheme(theme: Theme) {
        // First persist the selected theme using NSUserDefaults.
        UserDefaultsWrapper.storedTheme = theme
        
        UITabBar.appearance().tintColor = theme.mainColor
        UIToolbar.appearance().tintColor = theme.mainColor
        UINavigationBar.appearance().tintColor = theme.mainColor
    }
}
