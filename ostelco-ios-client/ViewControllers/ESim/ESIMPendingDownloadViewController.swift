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
    func resendEmail()
}

class ESIMPendingDownloadViewController: UIViewController {
    
    weak var delegate: ESIMPendingDownloadDelegate?
    var spinnerView: UIView?
    
    @IBOutlet private weak var continueButton: UIButton!

    @IBAction private func sendAgainTapped(_ sender: Any) {
        spinnerView = showSpinner(onView: self.view)
        delegate?.resendEmail()
    }
    
    @IBAction private func continueTapped(_ sender: Any) {
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
