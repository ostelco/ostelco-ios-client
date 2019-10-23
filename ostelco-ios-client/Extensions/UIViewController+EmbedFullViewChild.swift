//
//  UIViewController+EmbedFullViewChild.swift
//  ostelco-ios-client
//
//  Created by mac on 6/25/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

extension UIViewController {
    func embedFullViewChild(_ controller: UIViewController, removePrevious: Bool = true) {
        if removePrevious {
            for child in children {
                child.willMove(toParent: nil)
                child.view.removeFromSuperview()
                child.removeFromParent()
            }
        }
        guard let newView = controller.view else {
            return
        }
        view.addSubview(newView)
        newView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[newView]-(0)-|", options: [], metrics: nil, views: ["newView": newView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[newView]-(0)-|", options: [], metrics: nil, views: ["newView": newView]))
        view.bringSubviewToFront(newView)
        
        addChild(controller)
        controller.didMove(toParent: self)
    }
}
