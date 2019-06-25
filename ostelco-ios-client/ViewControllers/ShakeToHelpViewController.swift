//
//  ShakeToHelpViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 6/25/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class ShakeToHelpViewController: UIViewController {
    override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        
        switch motion {
        case .motionShake:
            let vc = self.topPresentedViewController()
            vc.showNeedHelpActionSheet()
        default:
            break
        }
    }
}
