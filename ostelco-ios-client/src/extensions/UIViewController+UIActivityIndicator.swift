//
//  UIViewController+UIActivityIndicator.swift
//  ostelco-ios-client
//
//  Created by mac on 3/5/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

// TODO: Could be a good idea to not have a global variable. Rather return the view from showSpinner, then use that as a parameter to removeSpinner
// ref: http://brainwashinc.com/2017/07/21/loading-activity-indicator-ios-swift/

extension UIViewController {
    func showSpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center

        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        return spinnerView
    }

    func removeSpinner(_ spinnerView: UIView?) {
        guard let spinnerView = spinnerView else { return }
        DispatchQueue.main.async {
            spinnerView.removeFromSuperview()
        }
    }
}
