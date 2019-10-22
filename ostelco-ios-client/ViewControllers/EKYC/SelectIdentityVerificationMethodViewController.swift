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
    @IBOutlet private var jumioRadioButton: RadioButton!
    @IBOutlet private var continueButton: UIButton!
    @IBOutlet private var singPassContainer: UIStackView!
    @IBOutlet private var scanICContainer: UIStackView!
    @IBOutlet private var jumioContainer: UIStackView!
    
    var spinnerView: UIView?
    var options: [IdentityVerificationOption]!
    
    private var radioButtons: [RadioButton] = []
        
    weak var delegate: SelectIdentityVerificationMethodDelegate?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        removeSpinner(spinnerView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setRadioButtons()
        self.toggleRadioButtonContainersVisibility()
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
        spinnerView = showSpinner()
        
        if self.singPassRadioButton.isCurrentSelected {
            OstelcoAnalytics.logEvent(.ChosenIDMethod(idMethod: "singpass"))
            self.delegate?.selected(option: .singpass)
        } else if self.scanICRadioButton.isCurrentSelected {
            OstelcoAnalytics.logEvent(.ChosenIDMethod(idMethod: "jumio"))
            self.delegate?.selected(option: .scanIC)
        } else if self.jumioRadioButton.isCurrentSelected {
            OstelcoAnalytics.logEvent(.ChosenIDMethod(idMethod: "jumio"))
            self.delegate?.selected(option: .jumio)
        } else {
            ApplicationErrors.assertAndLog("At least one of these should be checked if continue is enabled!")
        }
    }
    
    private func setRadioButtons() {
        self.options.forEach { option in
            switch option {
            case .singpass:
                radioButtons.append(self.singPassRadioButton)
            case .scanIC:
                radioButtons.append(self.scanICRadioButton)
            case .jumio:
                radioButtons.append(self.jumioRadioButton)
            }
        }
    }
    
    private func toggleRadioButtonContainersVisibility() {
        let excludedOptions = Set(IdentityVerificationOption.allCases).subtracting(Set(self.options))
        excludedOptions.forEach {
            switch $0 {
            case .singpass:
                self.singPassContainer.isHidden = true
            case .scanIC:
                self.scanICContainer.isHidden = true
            case .jumio:
                self.jumioContainer.isHidden = true
            }
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
    
    @IBAction private func jumioTapped(_ sender: Any) {
        self.selectRadioButton(self.jumioRadioButton)
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
