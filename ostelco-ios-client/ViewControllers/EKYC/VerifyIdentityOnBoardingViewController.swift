//
//  VerifyIdentityOnBoardingViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/5/19.
//  Copyright © 2019 mac. All rights reserved.
//

import OstelcoStyles
import UIKit

class VerifyIdentityOnBoardingViewController: UIViewController {
    
    @IBOutlet private var step1Icon: UIImageView!
    @IBOutlet private var step2Icon: UIImageView!
    
    weak var coordinator: EKYCCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tintColor = OstelcoColor.oyaBlue.toUIColor
        self.step1Icon.tintColor = tintColor
        self.step2Icon.tintColor = tintColor
    }
    
    @IBAction private func needHelpTapped(_ sender: Any) {
        showNeedHelpActionSheet()
    }
    
    @IBAction private func continueTapped(_ sender: Any) {
        self.coordinator?.showFirstStepAfterLanding()
    }
}

extension VerifyIdentityOnBoardingViewController: StoryboardLoadable {
    
    static var storyboard: Storyboard {
        return .ekyc
    }
    
    static var isInitialViewController: Bool {
        return true
    }
}
