//
//  ESIMOnBoardingViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/6/19.
//  Copyright © 2019 mac. All rights reserved.
//

import OstelcoStyles
import UIKit

class ESIMOnBoardingViewController: UIViewController {
    
    @IBOutlet private var step1Icon: UIImageView!
    @IBOutlet private var step2Icon: UIImageView!
    @IBOutlet private var step3Icon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tintColor = OstelcoColor.oyaBlue.toUIColor
        
        self.step1Icon.tintColor = tintColor
        self.step2Icon.tintColor = tintColor
        self.step3Icon.tintColor = tintColor
    }
    
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
