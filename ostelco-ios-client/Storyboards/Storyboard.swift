//
//  Storyboard.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/8/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

enum Storyboard: String, CaseIterable {
    case country = "Country"
    case ekyc = "EKYC"
    case esim = "ESim"
    case home = "Home"
    case login = "Login"
    case main = "Main"
    case signUp = "SignUp"
    case splash = "Splash"
    
    var asUIStoryboard: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: nil)
    }
    
    func initialViewController<T: UIViewController>() -> T {
        guard let vc = self.asUIStoryboard.instantiateInitialViewController() as? T else {
            fatalError("Could not instantiate initial VC in \(self.rawValue).storyboard as `\(String(describing: T.self))`")
        }
        
        return vc
    }
    
    func viewController<T: UIViewController>(with identifier: String) -> T {
        guard let vc = self.asUIStoryboard.instantiateViewController(withIdentifier: identifier) as? T else {
            fatalError("Could not instantiate VC in \(self.rawValue).storyboard with identifier \"\(identifier)\" as `\(String(describing: T.self))`")
        }
        
        return vc
    }
}
