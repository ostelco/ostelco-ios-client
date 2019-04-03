//
//  EKYCOhNoViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/6/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class EKYCOhNoViewController: UIViewController {
    @IBAction func contactSupportTapped(_ sender: Any) {
        Freshchat.sharedInstance()?.showConversations(self)
    }
}
