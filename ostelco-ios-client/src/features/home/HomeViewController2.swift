//
//  HomeViewController2.swift
//  ostelco-ios-client
//
//  Created by mac on 2/25/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class HomeViewController2: UIViewController {
    
    @IBOutlet weak var balanceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        balanceLabel.minimumScaleFactor = 0.1    //you need
        balanceLabel.adjustsFontSizeToFitWidth = true
        balanceLabel.lineBreakMode = .byClipping
        balanceLabel.numberOfLines = 0
    }
}
