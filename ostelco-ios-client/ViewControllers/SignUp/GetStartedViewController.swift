//
//  GetStartedViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/27/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import ostelco_core

protocol GetStartedDelegate: class {
    func enteredNickname(controller: UIViewController, nickname: String)
}

class GetStartedViewController: UIViewController {
    
    @IBOutlet private weak var continueButton: UIButton!
    @IBOutlet private weak var nameTextField: UITextField!

    weak var delegate: GetStartedDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        self.continueButton.isEnabled = false
    }
    
    @IBAction private func needHelpTapped() {
        self.showNeedHelpActionSheet()
    }
    
    @IBAction private func continueTapped(_ sender: Any) {
        guard let nickname = nameTextField.text else {
            ApplicationErrors.assertAndLog("No nickname but passed validation?!")
            return
        }
        
        OstelcoAnalytics.logEvent(.nicknameEntered)

        delegate?.enteredNickname(controller: self, nickname: nickname)
    }
}

extension GetStartedViewController: StoryboardLoadable {
    
    static var storyboard: Storyboard {
        return .signUp
    }
    
    static var isInitialViewController: Bool {
        return false
    }
}

extension GetStartedViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if !text.isEmpty {
            self.continueButton.isEnabled = true
        } else {
            self.continueButton.isEnabled = false
        }
        
        // Yes, we should allow these changes.
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        // We should not allow the input of a return
        return false
    }
}
