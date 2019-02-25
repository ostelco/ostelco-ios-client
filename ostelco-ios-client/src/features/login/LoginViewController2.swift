//
//  LoginViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/25/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

// TODO: Remove "2" when deleting existing LoginViewController
class LoginViewController2: UIViewController {
    
    @IBAction func closeFlow(_ sender: Any) {
        performSegue(withIdentifier: "unwindFromLoginViewController", sender: self)
    }
}
