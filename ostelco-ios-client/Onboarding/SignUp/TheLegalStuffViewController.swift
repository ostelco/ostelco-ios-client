//
//  TheLegalStuffViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/27/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

enum LegalLink: CaseIterable {
    case termsAndConditions
    case privacyPolicy
    case minimumAge
    
    var linkableText: LinkableText {
        switch self {
        case .termsAndConditions:
            return LinkableText(
                fullText: NSLocalizedString("I agree to the Terms & Conditions", comment: "Label for agreeing to the terms"),
                linkedPortion: Link(
                    NSLocalizedString("Terms & Conditions", comment: "Label for agreeing to the terms: linkable part"),
                    url: ExternalLink.termsAndConditions.url
                )
            )!
        case .privacyPolicy:
            return LinkableText(
                fullText: NSLocalizedString("I agree to the Privacy Policy", comment: "Label for agreeing to the privacy policy"),
                linkedPortion: Link(
                    NSLocalizedString("Privacy Policy", comment: "Label for agreeing to the privacy policy: linkable part"),
                    url: ExternalLink.privacyPolicy.url
                )
            )!
        case .minimumAge:
            return LinkableText(
                fullText: NSLocalizedString("I am at least 18 years of age", comment: "Label for being at least 18"),
                linkedPortion: Link(
                    NSLocalizedString("18 years", comment: "Label for being at least 18: linkable part"),
                    url: ExternalLink.minimumAgeDetails.url
                )
            )!
        }
    }
}

protocol TheLegalStuffDelegate: class {
    func legaleseAgreed()
}

class TheLegalStuffViewController: UIViewController {
    
    @IBOutlet private weak var termsAndConditionsLabel: BodyTextLabel!
    @IBOutlet private weak var privacyPolicyLabel: BodyTextLabel!
    @IBOutlet private weak var ageLabel: BodyTextLabel!
    
    @IBOutlet private weak var termsAndConditionsCheck: CheckButton!
    @IBOutlet private weak var privacyPolicyCheck: CheckButton!
    @IBOutlet private weak var ageCheck: CheckButton!

    @IBOutlet private weak var continueButton: UIButton!
    
    weak var delegate: TheLegalStuffDelegate?
 
    private var allChecks: [CheckButton] {
        return [
            termsAndConditionsCheck,
            privacyPolicyCheck,
            ageCheck
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        termsAndConditionsLabel.tapDelegate = self
        termsAndConditionsLabel.setLinkableText(LegalLink.termsAndConditions.linkableText)
        privacyPolicyLabel.tapDelegate = self
        privacyPolicyLabel.setLinkableText(LegalLink.privacyPolicy.linkableText)
        ageLabel.tapDelegate = self
        ageLabel.setLinkableText(LegalLink.minimumAge.linkableText)
        
        updateContinueButtonState()
    }

    @IBAction private func needHelpTapped() {
        showNeedHelpActionSheet()
    }
    
    @IBAction private func checkButtonTapped(_ check: CheckButton) {
        check.isChecked.toggle()
        updateContinueButtonState()
    }
    
    private func updateContinueButtonState() {
        if allChecks.contains(where: { !$0.isChecked }) {
            // At least one item is not checked.
            continueButton.isEnabled = false
        } else {
            // Everything is checked!
            continueButton.isEnabled = true
        }
    }
    
    @IBAction private func continueTapped() {
        OstelcoAnalytics.logEvent(.legalStuffAgreed)
        delegate?.legaleseAgreed()
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
    
    func tappedLink(_ link: Link) {
        UIApplication.shared.open(link.url)
    }
}
