//
//  VerifyCountryOnBoardingViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/28/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class VerifyCountryOnBoardingViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTitle()
    }

    @IBAction func needHelpTapped(_ sender: UIButton) {
        showNeedHelpActionSheet()
    }

    @IBAction func continueTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "displayChooseCountry", sender: self)
    }

    private func setTitle() {
        if let user = UserManager.sharedInstance.user {
            titleLabel.text = "Hi \(user.name)!"
        }
    }
}
