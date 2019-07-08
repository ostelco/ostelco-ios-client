//
//  SelectIdentityVerificationMethodViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import SafariServices
import OstelcoStyles

protocol SelectIdentityVerificationMethodDelegate: class {
    func selectedSingPass()
    func selectedNRIC()
}

class SelectIdentityVerificationMethodViewController: UIViewController {
    
    @IBOutlet private var singPassRadioButton: RadioButton!
    @IBOutlet private var scanICRadioButton: RadioButton!
    @IBOutlet private var continueButton: UIButton!
    
    private lazy var radioButtons: [RadioButton] = [
        self.singPassRadioButton,
        self.scanICRadioButton
    ]
        
    weak var delegate: SelectIdentityVerificationMethodDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateContinue()
    }

    @IBAction private func selectRadioButton(_ radioButton: RadioButton) {
        self.radioButtons.forEach { button in
            if button == radioButton {
                button.isCurrentSelected = true
            } else {
                button.isCurrentSelected = false
            }
        }
        
        self.updateContinue()
    }
    
    @IBAction private func continueTapped() {
        if self.singPassRadioButton.isCurrentSelected {
            OstelcoAnalytics.logEvent(.ChosenIDMethod(idMethod: "singpass"))
            self.delegate?.selectedSingPass()
        } else if self.scanICRadioButton.isCurrentSelected {
            OstelcoAnalytics.logEvent(.ChosenIDMethod(idMethod: "jumio"))
            self.delegate?.selectedNRIC()
        } else {
            ApplicationErrors.assertAndLog("At least one of these should be checked if continue is enabled!")
        }
    }
    
    private func updateContinue() {
        if self.radioButtons.contains(where: { $0.isCurrentSelected }) {
            self.continueButton.isEnabled = true
        } else {
            // No option has been selected yet. Disable.
            self.continueButton.isEnabled = false
        }
    }
    
    @IBAction private func needHelpTapped(_ sender: Any) {
        self.showNeedHelpActionSheet()
    }
    
    @IBAction private func singPassTapped() {
        self.selectRadioButton(self.singPassRadioButton)
    }
    
    @IBAction private func scanICTapped() {
        self.selectRadioButton(self.scanICRadioButton)
    }
}

extension SelectIdentityVerificationMethodViewController: StoryboardLoadable {
    
    static var storyboard: Storyboard {
        return .ekyc
    }
    
    static var isInitialViewController: Bool {
        return false
    }
}
