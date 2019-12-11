//
//  RemoteConfigViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 10/14/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import Firebase

class RemoteConfigViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        RemoteConfigManager.shared.fetch()
    }
}
