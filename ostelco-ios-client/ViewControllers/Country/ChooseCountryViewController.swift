//
//  ChooseCountryViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/28/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class ChooseCountryViewController: UIViewController {
    
    @IBOutlet private weak var picker: UIPickerView!
    @IBOutlet private weak var selectedCountryLabel: UILabel!
    
    @IBAction private func needHelpTapped(_ sender: Any) {
        showNeedHelpActionSheet()
    }
    
    @IBAction private func continueTapped(_ sender: Any) {
        performSegue(withIdentifier: "displayAllowLocationAccess", sender: self)
    }
}
