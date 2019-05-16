//
//  UIViewController+Notification.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 13/04/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

extension UIViewController {
    
    func addWillEnterForegroundObserver(selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func removeWillEnterForegroundObserver() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
}
