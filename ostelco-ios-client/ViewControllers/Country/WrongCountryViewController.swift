
//
//  WrongCountryViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/4/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class WrongCountryViewController: UIViewController {
    
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionLabel.text = "It seems like you are not in \(OnBoardingManager.sharedInstance.selectedCountry.name ?? "NO COUNTRY")"
    }
}
