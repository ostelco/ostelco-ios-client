//
//  TheLegalStuffViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/27/19.
//  Copyright © 2019 mac. All rights reserved.
//

import OstelcoStyles
import UIKit

enum LegalLink: CaseIterable {
    case termsAndConditions
    case privacyPolicy
    case minimumAge
    
    var linkableText: LinkableText {
        switch self {
        case .termsAndConditions:
            return LinkableText(fullText: "I hereby agree to the Terms & Conditions",
                                linkedPortion: "Terms & Conditions")!
        case .privacyPolicy:
            return LinkableText(fullText: "I agree to the Privacy Policy",
                                linkedPortion: "Privacy Policy")!
        case .minimumAge:
            return LinkableText(fullText: "I am at least 18 years of age",
                                linkedPortion: "18 years")!
        }
    }
    
    var linkToOpen: ExternalLink {
        switch self {
        case .termsAndConditions:
            return .termsAndConditions
        case .privacyPolicy:
            return .privacyPolicy
        case .minimumAge:
            return .minimumAgeDetails
        }
    }
}

class TheLegalStuffViewController: UIViewController {
    
    @IBOutlet private weak var termsAndConditionsLabel: BodyTextLabel!
    @IBOutlet private weak var privacyPolicyLabel: BodyTextLabel!
    @IBOutlet private weak var ageLabel: BodyTextLabel!
    
    @IBOutlet private weak var termsAndConditionsCheck: CheckButton!
    @IBOutlet private weak var privacyPolicyCheck: CheckButton!
    @IBOutlet private weak var ageCheck: CheckButton!

    @IBOutlet private weak var continueButton: UIButton!
 
    private var allChecks: [CheckButton] {
        return [
            self.termsAndConditionsCheck,
            self.privacyPolicyCheck,
            self.ageCheck
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.termsAndConditionsLabel.tapDelegate = self
        self.termsAndConditionsLabel.setLinkableText(LegalLink.termsAndConditions.linkableText)
        self.privacyPolicyLabel.tapDelegate = self
        self.privacyPolicyLabel.setLinkableText(LegalLink.privacyPolicy.linkableText)
        self.ageLabel.tapDelegate = self
        self.ageLabel.setLinkableText(LegalLink.minimumAge.linkableText)
        
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
}

extension TheLegalStuffViewController: StoryboardLoadable {
    
    static var storyboard: Storyboard {
        return .signUp
    }
    
    static var isInitialViewController: Bool {
        return true
    }
}

extension TheLegalStuffViewController: LabelTapDelegate {
    
    func tappedAttributedLabel(_ label: UILabel, at characterIndex: Int) {
        
        let legalLink: LegalLink
        switch label {
        case self.termsAndConditionsLabel:
            legalLink = .termsAndConditions
        case self.privacyPolicyLabel:
            legalLink = .privacyPolicy
        case self.ageLabel:
            legalLink = .minimumAge
        default:
            fatalError("Tapped an unhandled label!")
        }
        
        guard legalLink.linkableText.isIndexLinked(characterIndex) else {
            // Did not actually tap the link
            return
        }
        
        UIApplication.shared.open(legalLink.linkToOpen.url)
    }
}
