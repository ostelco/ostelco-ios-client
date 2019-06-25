//
//  UIViewController+EmbedFullViewChild.swift
//  ostelco-ios-client
//
//  Created by mac on 6/25/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

extension UIViewController {
    func embedFullViewChild(_ controller: UIViewController) {
        for child in children {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
        let newView = controller.view
        view.addSubview(newView!)
        newView?.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[newView]-(0)-|", options: [], metrics: nil, views: ["newView" : newView!]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[newView]-(0)-|", options: [], metrics: nil, views: ["newView" : newView!]))
        
        addChild(controller)
        controller.didMove(toParent: self)
    }
}
