//
//  SignupViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/25/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    @IBAction func closeFlow(_ sender: Any) {
        performSegue(withIdentifier: "unwindFromSignUpViewController", sender: self)
    }
}
