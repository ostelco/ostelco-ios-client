//
//  EKYCWaitViewController.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 28/02/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class EKYCWaitViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  @IBAction func `continue`(_ sender: Any) {
    performSegue(withIdentifier: "unwindFromEKYCWaitViewController", sender: self)
  }
}
