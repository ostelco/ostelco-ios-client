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

class NRICVerifyViewController: UIViewController {
    
    var spinnerView: UIView?
    @IBOutlet private weak var nricTextField: UITextField!
    @IBOutlet private weak var nricErrorLabel: UILabel!
    
    weak var coordinator: SingaporeEKYCCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction private func needHelpTapped(_ sender: Any) {
        self.showNeedHelpActionSheet()
    }
    
    @IBAction private func continueTapped(_ sender: Any) {
        guard
            let nric = self.nricTextField.text,
            nric.isNotEmpty else {
                self.showAlert(title: "Error", msg: "NRIC field can't be empty")
                return
        }
        
        let countryCode = OnBoardingManager.sharedInstance.selectedCountry.countryCode.lowercased()
        self.nricErrorLabel.isHidden = true
        self.spinnerView = self.showSpinner(onView: self.view)
        APIManager.shared.primeAPI
            .validateNRIC(nric, forRegion: countryCode)
            .ensure { [weak self] in
                self?.removeSpinner(self?.spinnerView)
            }
            .done { [weak self] isValid in
                if isValid {
                    self?.coordinator?.enteredNRICSuccessfully()
                } else {
                    self?.nricErrorLabel.isHidden = false
                }
            }
            .catch { [weak self] error in
                ApplicationErrors.log(error)
                self?.showGenericError(error: error)
            }
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
