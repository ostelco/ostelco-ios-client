//
//  TheLegalStuffViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/27/19.
//  Copyright © 2019 mac. All rights reserved.
//

import OstelcoStyles
import UIKit

class TheLegalStuffViewController: UIViewController {
    
    enum ExternalLinks: String {
        case privacyPolicy = "https://pi-redirector.firebaseapp.com/privacy-policy"
        case termsAndConditions = "https://pi-redirector.firebaseapp.com/terms-and-conditions"
    }
    
    @IBOutlet private weak var termsAndConditionsLabel: BodyTextLabel!
    @IBOutlet private weak var privacyPolicyLabel: BodyTextLabel!
    
    @IBOutlet private weak var termsAndConditionsCheck: CheckButton!
    @IBOutlet private weak var privacyPolicyCheck: CheckButton!
    
    @IBOutlet private weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.termsAndConditionsLabel.setFullText("I hereby agree to the Terms & Conditions", withBoldedPortion: "Terms & Conditions")
        self.termsAndConditionsLabel.isUserInteractionEnabled = true
        let termsAndConditionsTapHandler = UITapGestureRecognizer(target: self, action: #selector(termsAndConditionsTapped))
        self.termsAndConditionsLabel.addGestureRecognizer(termsAndConditionsTapHandler)

        self.privacyPolicyLabel.setFullText("I agree to the Privacy Policy", withBoldedPortion: "Privacy Policy")
        self.privacyPolicyLabel.isUserInteractionEnabled = true
        let privacyPolicyTapHandler = UITapGestureRecognizer(target: self, action: #selector(privacyPolicyTapped))
        self.privacyPolicyLabel.addGestureRecognizer(privacyPolicyTapHandler)

        self.updateContinueButtonState()
    }

    @IBAction private func checkButtonTapped(_ check: CheckButton) {
        check.isChecked.toggle()
    }
    
    private func updateContinueButtonState() {
        if self.termsAndConditionsCheck.isChecked && self.privacyPolicyCheck.isChecked {
            self.continueButton.isEnabled = true
        } else {
            self.continueButton.isEnabled = false
        }
    }
    
    @objc func termsAndConditionsTapped(sender: UITapGestureRecognizer) {
        guard let url = URL(string: ExternalLinks.termsAndConditions.rawValue) else { return }
        UIApplication.shared.open(url)
    }
    
    @objc func privacyPolicyTapped(sender: UITapGestureRecognizer) {
        guard let url = URL(string: ExternalLinks.privacyPolicy.rawValue) else { return }
        UIApplication.shared.open(url)
    }
}
