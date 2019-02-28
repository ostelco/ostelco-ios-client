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
        let alert = UIAlertController(title: "Halp!!!", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func continueTapped(_ sender: Any) {
        performSegue(withIdentifier: "displayChooseCountry", sender: self)
    }
}
