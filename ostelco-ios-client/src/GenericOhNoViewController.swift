//
//  GenericOhNoViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 4/3/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class GenericOhNoViewController: UIViewController {
    @IBAction func contactSupportTapped(_ sender: Any) {
        Freshchat.sharedInstance()?.showConversations(self)
    }
}
