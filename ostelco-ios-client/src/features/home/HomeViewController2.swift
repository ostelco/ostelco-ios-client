//
//  HomeViewController2.swift
//  ostelco-ios-client
//
//  Created by mac on 2/25/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class HomeViewController2: UIViewController {
    @IBAction func closeFlow(_ sender: Any) {
        performSegue(withIdentifier: "unwindFromHomeViewController", sender: self)
    }
}
