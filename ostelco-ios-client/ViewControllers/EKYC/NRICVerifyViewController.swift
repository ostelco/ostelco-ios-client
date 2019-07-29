//
//  NRICVerifyViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Crashlytics
import ostelco_core
import PromiseKit
import UIKit

protocol NRICVerifyDelegate: class {
    func enteredNRICS(_ controller: NRICVerifyViewController, nric: String)
}

class NRICVerifyViewController: UIViewController {
    
    var spinnerView: UIView?
    @IBOutlet private weak var nricTextField: UITextField!
    @IBOutlet private weak var nricErrorLabel: UILabel!
    
    weak var delegate: NRICVerifyDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
    }
    
    @IBAction private func needHelpTapped(_ sender: Any) {
        showNeedHelpActionSheet()
    }
    
    @IBAction private func continueTapped(_ sender: Any) {
        guard let nric = nricTextField.text, nric.isNotEmpty else {
            showAlert(title: "Error", msg: "NRIC field can't be empty")
            return
        }
        
        nricErrorLabel.isHidden = true
        delegate?.enteredNRICS(self, nric: nric)
    }
    
    func showError() {
        nricErrorLabel.isHidden = false
    }
}

extension NRICVerifyViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        // No, returns should not be added to the text.
        return false
    }
}

extension NRICVerifyViewController: StoryboardLoadable {
    
    static var storyboard: Storyboard {
        return .ekyc
    }
    
    static var isInitialViewController: Bool {
        return false
    }
}
