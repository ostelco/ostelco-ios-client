//
//  EnableNotificationsViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/27/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import UserNotifications

class EnableNotificationsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        OstelcoAnalytics.logEvent(.LegalStuffAgreed)
    }
    
    @IBAction private func continueTapped() {
        self.requestNotificationAuthorization()
    }
    
    @IBAction private func needHelpTapped() {
        self.showNeedHelpActionSheet()
    }

    private func requestNotificationAuthorization() {
        PushNotificationController.shared.checkSettingsThenRegisterForNotifications(authorizeIfNotDetermined: true)
            .done { [weak self] _ in
                self?.showGetStarted()
            }
            .catch { [weak self] error in
                switch error {
                case PushNotificationController.Error.notAuthorized:
                    // The user declined push notifications. Oh well. Let's move on.
                    self?.showGetStarted()
                default:
                    ApplicationErrors.log(error)
                    self?.showGenericError(error: error)
                }
            }
    }
    
    private func showGetStarted() {
        self.performSegue(withIdentifier: "displayGetStarted", sender: self)
    }
}
