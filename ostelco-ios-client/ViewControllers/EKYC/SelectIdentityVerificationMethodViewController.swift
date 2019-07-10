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
import ostelco_core

protocol SelectIdentityVerificationMethodDelegate: class {
    func selected(option: IdentityVerificationOption)
}

class SelectIdentityVerificationMethodViewController: UIViewController {
    
    @IBOutlet private var singPassRadioButton: RadioButton!
    @IBOutlet private var scanICRadioButton: RadioButton!
    @IBOutlet private var continueButton: UIButton!
    
    var spinnerView: UIView?
    
    private lazy var radioButtons: [RadioButton] = [
        self.singPassRadioButton,
        self.scanICRadioButton
    ]
        
    weak var delegate: SelectIdentityVerificationMethodDelegate?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        removeSpinner(spinnerView)
    }
    
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
        spinnerView = showSpinner(onView: self.view)
        
        if self.singPassRadioButton.isCurrentSelected {
            OstelcoAnalytics.logEvent(.ChosenIDMethod(idMethod: "singpass"))
            self.delegate?.selected(option: .singpass)
        } else if self.scanICRadioButton.isCurrentSelected {
            OstelcoAnalytics.logEvent(.ChosenIDMethod(idMethod: "jumio"))
            self.delegate?.selected(option: .scanIC)
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
