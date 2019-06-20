//
//  FreshchatManager.swift
//  ostelco-ios-client
//
//  Created by mac on 6/20/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class FreshchatManager {
    
    static let shared = FreshchatManager()
    
    func show(_ viewController: UIViewController) {
        Freshchat.sharedInstance()?.showFAQs(viewController)
    }
}
