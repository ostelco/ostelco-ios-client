//
//  GetStartedViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/27/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import JWTDecode

class GetStartedViewController: UIViewController {
    var spinnerView: UIView?

    @IBAction func continueTapped(_ sender: Any) {
        spinnerView = showSpinner(onView: self.view)
        let email = getEmailFromJWT()
        
        if let email = email {
            APIManager.sharedInstance.customer.withParam("nickname", nameTextField.text!).withParam("contactEmail", email).request(.post, json: [:])
                .onSuccess({ data in
                    if let customer: CustomerModel = data.typedContent(ifNone: nil) {
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
            showAlert(title: "Error", msg: "Email is empty or missing in claims")
        }
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

    private func getEmailFromJWT() -> String? {
        do {
            let jwt = try decode(jwt: UserManager.sharedInstance.authToken!)
            if let email = jwt.email {
                return email
            }
        } catch {
            showGenericError(error: error)
        }
        return nil
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
