//
//  ChooseCountryOnBoardingViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/28/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class ChooseCountryOnBoardingViewController: UIViewController {
    
    @IBAction func needHelpTapped(_ sender: Any) {
        showNeedHelpActionSheet()
    }
    
    @IBAction func continueTapped(_ sender: Any) {
        performSegue(withIdentifier: "displayChooseCountry", sender: self)
    }
}
