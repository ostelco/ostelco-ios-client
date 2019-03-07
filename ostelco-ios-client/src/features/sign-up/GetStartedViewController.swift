//
//  GetStartedViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/27/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class GetStartedViewController: UIViewController {
    
    @IBAction func continueTapped(_ sender: Any) {
        performSegue(withIdentifier: "showCountry", sender: self)
    }
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        continueButton.backgroundColor = ThemeManager.currentTheme().mainColor.withAlphaComponent(CGFloat(0.15))
        continueButton.isEnabled = false
        nameTextField.delegate = self
    }
}

extension GetStartedViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if !text.isEmpty{
            continueButton.isEnabled = true
            continueButton.backgroundColor = ThemeManager.currentTheme().mainColor
        } else {
            continueButton.isEnabled = false
            continueButton.backgroundColor = ThemeManager.currentTheme().mainColor.withAlphaComponent(CGFloat(0.15))
        }
        
        return true
    }
}
