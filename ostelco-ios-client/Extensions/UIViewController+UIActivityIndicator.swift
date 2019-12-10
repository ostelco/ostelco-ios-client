//
//  UIViewController+UIActivityIndicator.swift
//  ostelco-ios-client
//
//  Created by mac on 3/5/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

// ref: https://github.com/vincechan/SwiftLoadingIndicator/blob/master/SwiftLoadingIndicator/LoadingIndicatorView.swift

extension UIViewController {
    @discardableResult func showSpinner(loadingText: String? = nil) -> UIView {
        
        // Create the overlay
        let overlay = UIView()
        overlay.alpha = 0
        overlay.backgroundColor = OstelcoColor.background.toUIColor
        overlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlay)
        view.bringSubviewToFront(overlay)
        
        overlay.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        overlay.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        // Create and animate the activity indicator
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = OstelcoColor.background.toUIColor
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        overlay.addSubview(indicator)
        
        indicator.centerXAnchor.constraint(equalTo: overlay.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: overlay.centerYAnchor).isActive = true
        
        // Create label
        if let textString = loadingText {
            let label = UILabel()
            label.text = textString
            label.textColor = OstelcoColor.background.toUIColor
            overlay.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.bottomAnchor.constraint(equalTo: indicator.topAnchor, constant: -32).isActive = true
            label.centerXAnchor.constraint(equalTo: indicator.centerXAnchor).isActive = true
        }
        
        // Animate the overlay to show
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            overlay.alpha = overlay.alpha > 0 ? 0 : 0.88
        }, completion: nil)

        return overlay
    }
    
    func removeSpinner(_ spinnerView: UIView?) {
        guard let spinnerView = spinnerView else { return }
        DispatchQueue.main.async {
            spinnerView.removeFromSuperview()
        }
    }
}
