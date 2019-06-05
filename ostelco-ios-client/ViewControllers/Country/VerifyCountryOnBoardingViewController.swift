//
//  VerifyCountryOnBoardingViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/28/19.
//  Copyright © 2019 mac. All rights reserved.
//

import OstelcoStyles
import UIKit

class VerifyCountryOnBoardingViewController: UIViewController {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var selectedStepIcon: UIImageView!
    
    weak var coordinator: CountryCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectedStepIcon.tintColor = OstelcoColor.oyaBlue.toUIColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setTitle()
    }
    
    @IBAction private func needHelpTapped(_ sender: UIButton) {
        showNeedHelpActionSheet()
    }
    
    @IBAction private func continueTapped(_ sender: UIButton) {
        self.coordinator?.finishedViewingCountryLandingScreen()
    }
    
    private func setTitle() {
        if let user = UserManager.shared.customer {
            self.titleLabel.text = "Hi \(user.name)!"
        }
    }
}

extension VerifyCountryOnBoardingViewController: StoryboardLoadable {
    
    static var storyboard: Storyboard {
        return .country
    }
    
    static var isInitialViewController: Bool {
        return false
    }
}
