//
//  ChooseCountryOnBoardingViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/28/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import Firebase

class ChooseCountryOnBoardingViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTitle()
    }
    
    @IBAction func needHelpTapped(_ sender: UIButton) {
        Analytics.logEvent("button_tapped", parameters: ["newValue": sender.title(for: .normal)!])
        showNeedHelpActionSheet()
    }
    
    @IBAction func continueTapped(_ sender: UIButton) {
        Analytics.logEvent("button_tapped", parameters: ["newValue": sender.title(for: .normal)!])
        performSegue(withIdentifier: "displayChooseCountry", sender: self)
    }
    
    private func setTitle() {
        if let user = UserManager.sharedInstance.user {
            titleLabel.text = "Hi \(user.name)!"
        }
    }
}
