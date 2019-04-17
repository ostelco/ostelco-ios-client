//
//  UIViewController+Presentation.swift
//  ostelco-ios-client
//
//  Created by mac on 4/11/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /// Goes up a hierarchy of presented view controllers to find the topmost one.
    ///
    /// - Returns: The caller if no further presenters are available.
    ///            Otherwise, the `topPresentedViewController()` of the vc this one is presenting.
    func topPresentedViewController() -> UIViewController {
        guard let presented = self.presentedViewController else {
            return self
        }
        
        return presented.topPresentedViewController()
    }
}
