//
//  GetStartedViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/27/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import ostelco_core

class GetStartedViewController: UIViewController {
    
    @IBOutlet private weak var continueButton: UIButton!
    @IBOutlet private weak var nameTextField: UITextField!
    
    var spinnerView: UIView?
    
    var coordinator: SignUpCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        self.continueButton.isEnabled = false
    }
    
    @IBAction private func needHelpTapped() {
        self.showNeedHelpActionSheet()
    }
    
    @IBAction private func continueTapped(_ sender: Any) {
        guard let email = UserManager.shared.currentUserEmail else {
            self.showAlert(title: "Error", msg: "Email is empty or missing in Firebase")
            return
        }
        
        guard let nickname = self.nameTextField.text else {
            ApplicationErrors.assertAndLog("No nickname but passed validation?!")
            return
        }
        
        self.spinnerView = self.showSpinner(onView: self.view)
        let user = UserSetup(nickname: nickname, email: email)

        APIManager.shared.primeAPI.createCustomer(with: user)
            .ensure { [weak self] in
                self?.removeSpinner(self?.spinnerView)
                self?.spinnerView = nil
            }
            .done { [weak self] customer in
                OstelcoAnalytics.logEvent(.EnteredNickname)
                UserManager.shared.customer = customer
                self?.coordinator?.nameEnteredSuccessfully()
            }
            .catch { [weak self] error in
                ApplicationErrors.log(error)
                self?.showGenericError(error: error)
            }
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
