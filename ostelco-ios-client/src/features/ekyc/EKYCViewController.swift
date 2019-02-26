//
//  EKYCViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/25/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class EKYCViewController: UIViewController {
    @IBAction func closeFlow(_ sender: Any) {
        performSegue(withIdentifier: "unwindFromEKYCViewController", sender: self)
    }
}
