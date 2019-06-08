//
//  UIWindow+ShakeToOpenHelp.swift
//  ostelco-ios-client
//
//  Created by mac on 6/8/19.
//  Copyright © 2019 mac. All rights reserved.
//

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            guard let vc = UIApplication.shared.typedDelegate.rootCoordinator.topViewController else {
                //
                debugPrint("Can't show need help action sheet, there's no view controller to show.")
                return
            }
            
            if let nav = vc as? UINavigationController {
                nav.showNeedHelpActionSheet()
            } else if let tab = vc as? UITabBarController {
                tab.showNeedHelpActionSheet()
            } else {
                vc.topPresentedViewController().showNeedHelpActionSheet()
            }
        }
    }
}
