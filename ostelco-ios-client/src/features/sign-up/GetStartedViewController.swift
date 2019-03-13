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
    
    @IBAction func continueTapped(_ sender: Any) {
        self.showSpinner(onView: self.view)
        let email = getEmailFromJWT()
        
        if email != nil {
            APIManager.sharedInstance.customer.request(.post, json: ["name": nameTextField.text!, "email": email])
                .onSuccess({ data in
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "showCountry", sender: self)
                    }
                })
                .onFailure({ error in
                    self.showAPIError(error: error)
                })
                .onCompletion({ _ in
                    self.removeSpinner()
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
