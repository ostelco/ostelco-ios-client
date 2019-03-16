//
//  SelectIdentityVerificationMethodViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class SelectIdentityVerificationMethodViewController: UIViewController {
    
    @IBAction func singPassTapped(_ sender: Any) {
        performSegue(withIdentifier: "myInfoSummary", sender: self)
    }
    
    @IBAction func nricTapped(_ sender: Any) {
        performSegue(withIdentifier: "nricVerify", sender: self)
    }
    
    @IBAction func needHelpTapped(_ sender: Any) {
        showNeedHelpActionSheet()
    }
}
