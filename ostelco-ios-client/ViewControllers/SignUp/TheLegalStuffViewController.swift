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
    
    enum ExternalLink: String {
        case privacyPolicy = "https://pi-redirector.firebaseapp.com/privacy-policy"
        case termsAndConditions = "https://pi-redirector.firebaseapp.com/terms-and-conditions"

        var url: URL {
            guard let url = URL(string: self.rawValue) else {
                fatalError("Could not create URL from \(self.rawValue)")
            }

            return url
        }
    }
    
    @IBOutlet private weak var termsAndConditionsLabel: BodyTextLabel!
    @IBOutlet private weak var privacyPolicyLabel: BodyTextLabel!
    
    @IBOutlet private weak var termsAndConditionsCheck: CheckButton!
    @IBOutlet private weak var privacyPolicyCheck: CheckButton!
    
    private var allChecks: [CheckButton] {
        return [
            self.termsAndConditionsCheck,
            self.privacyPolicyCheck
        ]
    }
    
    @IBOutlet private weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.termsAndConditionsLabel.setFullText("I hereby agree to the Terms & Conditions", withBoldedPortion: "Terms & Conditions")
        self.privacyPolicyLabel.setFullText("I agree to the Privacy Policy", withBoldedPortion: "Privacy Policy")

        self.updateContinueButtonState()
    }

    @IBAction private func checkButtonTapped(_ check: CheckButton) {
        check.isChecked.toggle()
    }
    
    private func updateContinueButtonState() {
        if self.allChecks.contains(where: { !$0.isChecked }) {
            // At least one item is not checked.
            self.continueButton.isEnabled = false
        } else {
            // Everything is checked!
            self.continueButton.isEnabled = true
        }
    }
    
    @IBAction private func termsAndConditionsTapped(sender: UITapGestureRecognizer) {
        UIApplication.shared.open(ExternalLink.termsAndConditions.url)
    }
    
    @IBAction private func privacyPolicyTapped(sender: UITapGestureRecognizer) {
        UIApplication.shared.open(ExternalLink.privacyPolicy.url)
    }
}
