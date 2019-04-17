//
//  UIViewController+Gesture.swift
//  ostelco-ios-client
//
//  Created by mac on 4/11/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

extension UIViewController {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            showNeedHelpActionSheet()
        }
    }

    override open var canBecomeFirstResponder: Bool {
        return true
    }
}
