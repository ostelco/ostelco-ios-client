//
//  SignUpCompletedViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class SignUpCompletedViewController: UIViewController {

    @IBAction private func continueTapped(_ sender: Any) {
        performSegue(withIdentifier: "home", sender: self)
    }
}
