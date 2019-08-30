//
//  ESIMPendingDownloadViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/6/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import Crashlytics
import ostelco_core

protocol ESIMPendingDownloadDelegate: class {
    func checkAgain()
    func resendEmail(controller: UIViewController)
}

class ESIMPendingDownloadViewController: UIViewController {
    
    weak var delegate: ESIMPendingDownloadDelegate?

    @IBOutlet private weak var continueButton: UIButton!

    @IBAction private func sendAgainTapped(_ sender: Any) {
        delegate?.resendEmail(controller: self)
    }
    
    @IBAction private func continueTapped(_ sender: Any) {
        OstelcoAnalytics.logEvent(.ESimOnboardingPending)
        delegate?.checkAgain()
    }
    
    @IBAction private func needHelpTapped(_ sender: Any) {
        self.showNeedHelpActionSheet()
    }
}

extension ESIMPendingDownloadViewController: StoryboardLoadable {
    
    static var storyboard: Storyboard {
        return .esim
    }
    
    static var isInitialViewController: Bool {
        return false
    }
}
