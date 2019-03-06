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
    
    var countries = ["Germany", "Ireland", "Norway", "Singapore", "Sweden", "U.K.", "USA"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        let defaultRow = countries.firstIndex(of: "Singapore") ?? countries.count / 2
        picker.selectRow(defaultRow, inComponent: 0, animated: false)
    }
    
    @IBAction func needHelpTapped(_ sender: Any) {
        showNeedHelpActionSheet()
    }
    
    @IBAction func continueTapped(_ sender: Any) {
        performSegue(withIdentifier: "displayAllowLocationAccess", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let selectedRow = picker.selectedRow(inComponent: 0)
        let selectedCountry = countries[selectedRow]
        
        let vc = segue.destination as! AllowLocationAccessViewController
        vc.selectedCountry = selectedCountry
    }
}

extension ChooseCountryViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countries[row]
    }
}

extension ChooseCountryViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countries.count
    }
}
