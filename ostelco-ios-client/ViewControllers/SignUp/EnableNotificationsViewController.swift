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
    
    var coordinator: SignUpCoordinator?
    
    @IBAction private func continueTapped() {
        self.requestNotificationAuthorization()
    }
    
    @IBAction private func needHelpTapped() {
        self.showNeedHelpActionSheet()
    }

    private func requestNotificationAuthorization() {
        PushNotificationController.shared.checkSettingsThenRegisterForNotifications(authorizeIfNotDetermined: true)
            .done { [weak self] _ in
                self?.coordinator?.pushAgreedOrDenied()
            }
            .catch { [weak self] error in
                switch error {
                case PushNotificationController.Error.notAuthorized:
                    // The user declined push notifications. Oh well. Let's move on.
                    self?.coordinator?.pushAgreedOrDenied()
                default:
                    ApplicationErrors.log(error)
                    self?.showGenericError(error: error)
                }
            }
    }
}

extension EnableNotificationsViewController: StoryboardLoadable {
    
    static var storyboard: Storyboard {
        return .signUp
    }
    
    static var isInitialViewController: Bool {
        return false
    }
}
