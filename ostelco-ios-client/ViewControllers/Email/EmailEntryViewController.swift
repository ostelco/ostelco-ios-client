//
//  EmailEntryViewController.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 5/7/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

protocol EmailEntryDelegate: class {
    func sendEmailLink(email: String)
}

class EmailEntryViewController: UIViewController {
    
    @IBOutlet private var emailTextField: UITextField!
    @IBOutlet private var errorLabel: UILabel!
    @IBOutlet private var continueButton: UIButton!
    
    weak var delegate: EmailEntryDelegate?
    
    private let emailValidator = EmailValidator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.configureForValidationState()
    }
    
    @IBAction private func continueTapped() {
        guard let email = self.emailTextField.text else {
            ApplicationErrors.assertAndLog("Email validation passed but the field was nil?!")
            return
        }
        
        delegate?.sendEmailLink(email: email)
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

extension EmailEntryViewController: StoryboardLoadable {
    
    static var storyboard: Storyboard {
        return .email
    }
    
    static var isInitialViewController: Bool {
        return true
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
