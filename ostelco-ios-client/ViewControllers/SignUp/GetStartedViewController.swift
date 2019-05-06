//
//  GetStartedViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/27/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import JWTDecode
import ostelco_core

class GetStartedViewController: UIViewController {
    
    @IBOutlet private weak var continueButton: UIButton!
    @IBOutlet private weak var nameTextField: UITextField!
    
    var spinnerView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        self.continueButton.isEnabled = false
    }
    
    @IBAction private func needHelpTapped() {
        self.showNeedHelpActionSheet()
    }
    
    @IBAction private func continueTapped(_ sender: Any) {
        self.spinnerView = showSpinner(onView: self.view)
        let email = self.getEmailFromJWT()
        
        if let email = email {
            APIManager.sharedInstance.customer.withParam("nickname", nameTextField.text!).withParam("contactEmail", email).request(.post, json: [:])
                .onSuccess({ data in
                    if let customer: CustomerModel = data.typedContent(ifNone: nil) {
                        OstelcoAnalytics.logEvent(.EnteredNickname)
                        DispatchQueue.main.async {
                            UserManager.sharedInstance.user = customer
                            self.performSegue(withIdentifier: "showCountry", sender: self)
                        }
                    } else {
                        self.showAlert(title: "Error", msg: "Something unexpected happened. Try again later.")
                    }
                })
                .onFailure({ error in
                    self.showAPIError(error: error)
                })
                .onCompletion({ _ in
                    self.removeSpinner(self.spinnerView)
                })
        } else {
            self.showAlert(title: "Error", msg: "Email is empty or missing in claims")
        }
    }

    private func getEmailFromJWT() -> String? {
        do {
            let jwt = try decode(jwt: UserManager.sharedInstance.authToken!)
            if let email = jwt.email {
                return email
            }
        } catch {
            self.showGenericError(error: error)
        }
        return nil
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
