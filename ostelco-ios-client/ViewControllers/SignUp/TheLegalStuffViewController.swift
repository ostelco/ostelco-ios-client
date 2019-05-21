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
    
    @IBOutlet private weak var termsAndConditionsLabel: BodyTextLabel!
    @IBOutlet private weak var privacyPolicyLabel: BodyTextLabel!
    @IBOutlet private weak var ageLabel: BodyTextLabel!
    
    @IBOutlet private weak var termsAndConditionsCheck: CheckButton!
    @IBOutlet private weak var privacyPolicyCheck: CheckButton!
    @IBOutlet private weak var ageCheck: CheckButton!
    
    private var allChecks: [CheckButton] {
        return [
            self.termsAndConditionsCheck,
            self.privacyPolicyCheck,
            self.ageCheck
        ]
    }
    
    @IBOutlet private weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.termsAndConditionsLabel.setFullText("I hereby agree to the Terms & Conditions", withBoldedPortion: "Terms & Conditions")
        self.privacyPolicyLabel.setFullText("I agree to the Privacy Policy", withBoldedPortion: "Privacy Policy")
        self.ageLabel.setFullText("I am at least 18 years of age", withBoldedPortion: "18 years")
        
        self.updateContinueButtonState()
    }

    @IBAction private func needHelpTapped() {
        self.showNeedHelpActionSheet()
    }
    
    @IBAction private func checkButtonTapped(_ check: CheckButton) {
        check.isChecked.toggle()
        self.updateContinueButtonState()
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
    
    @IBAction private func ageTapped(sender: UITapGestureRecognizer) {
        #warning("Get actual link for this before launch!")
        self.showAlert(title: "Placeholder", msg: "Must get actual URL here!")
    }
}

extension TheLegalStuffViewController: StoryboardLoadable {
    
    static var storyboard: Storyboard {
        return .signUp
    }
    
    static var isInitialViewController: Bool {
        return true
    }
}
