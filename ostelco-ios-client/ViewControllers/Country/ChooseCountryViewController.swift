//
//  ChooseCountryViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/28/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class ChooseCountryViewController: UIViewController {
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var selectedCountryLabel: UILabel!

    @IBAction func needHelpTapped(_ sender: Any) {
        showNeedHelpActionSheet()
    }
    
    @IBAction func continueTapped(_ sender: Any) {
        performSegue(withIdentifier: "displayAllowLocationAccess", sender: self)
    }
}
