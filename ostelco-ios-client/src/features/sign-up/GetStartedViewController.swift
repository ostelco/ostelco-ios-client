//
//  GetStartedViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/27/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class GetStartedViewController: UIViewController {
    
    @IBAction func continueTapped(_ sender: Any) {
        performSegue(withIdentifier: "unwindFromSignUpViewController", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
    }
}
