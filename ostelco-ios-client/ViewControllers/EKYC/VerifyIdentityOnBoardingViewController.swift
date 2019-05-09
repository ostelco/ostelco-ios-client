//
//  VerifyIdentityOnBoardingViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/5/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class VerifyIdentityOnBoardingViewController: UIViewController {
    
    @IBAction private func needHelpTapped(_ sender: Any) {
        showNeedHelpActionSheet()
    }
    
    @IBAction private func continueTapped(_ sender: Any) {
        performSegue(withIdentifier: "selectIdentityVerificationMethod", sender: self)
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
