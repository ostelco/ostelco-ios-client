//
//  TabBarViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 10/18/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    override func viewDidLoad() {
        embedSwiftUI(TabBarView(controller: self))
    }
    
    func showFreshchat() {
        FreshchatManager.shared.show(self)
    }
}
