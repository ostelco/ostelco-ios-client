//
//  EmailEntryViewController.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 5/7/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class EmailEntryViewController: UIViewController {
    
    @IBOutlet private var emailTextField: UITextField!
    @IBOutlet private var errorLabel: UILabel!
    @IBOutlet private var continueButton: UIButton!
    
    private let emailValidator = EmailValidator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.configureForValidationState()
    }
    
    @IBAction private func continueTapped() {
        guard let email = self.emailTextField.text else {
            assertionFailure("Email validation passed but the field was nil?!")
            return
        }
        
        let spinnerView = self.showSpinner(onView: self.view)
        EmailLinkManager.linkEmail(email)
            .ensure { [weak self] in
                self?.removeSpinner(spinnerView)
            }
            .done { [weak self] in
                self?.showCheckYourEmailVC()
            }
            .catch { [weak self] error in
                ApplicationErrors.log(error)
                self?.showGenericError(error: error)
            }
    }
    
    private func showCheckYourEmailVC() {
        self.performSegue(withIdentifier: "showCheckEmail", sender: self)
    }
    
    private func configureForValidationState() {
        switch self.emailValidator.validationState {
        case .notChecked:
            self.errorLabel.text = nil
            self.continueButton.isEnabled = false
        case .valid:
            self.errorLabel.text = nil
            self.continueButton.isEnabled = true
        case .error(let description):
            self.continueButton.isEnabled = false
            self.errorLabel.text = description
        }
    }
}

extension EmailEntryViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        
        self.emailValidator.email = text
        self.configureForValidationState()
        
        // Yes, allow these changes.
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        // No, returns should not be allowed.
        return false
    }
}
