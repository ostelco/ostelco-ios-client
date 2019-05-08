//
//  ESIMOnBoardingViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/6/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class ESIMOnBoardingViewController: UIViewController {
    
    @IBAction private func continueTapped(_ sender: Any) {
        OstelcoAnalytics.logEvent(.DownloadingESIM)
        performSegue(withIdentifier: "showESIMInstructions", sender: self)
    }
    
    @IBAction private func needHelpTapped(_ sender: Any) {
        showNeedHelpActionSheet()
    }
}

extension ESIMOnBoardingViewController: StoryboardLoadable {
    
    static var storyboard: Storyboard {
        return .esim
    }
    
    static var isInitialViewController: Bool {
        return true
    }
}
