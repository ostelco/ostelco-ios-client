//
//  EnableNotificationsViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/27/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import UserNotifications

protocol EnableNotificationsDelegate: class {
    func requestPermission()
}

class EnableNotificationsViewController: UIViewController {
    
    weak var delegate: EnableNotificationsDelegate?
    
    @IBAction private func continueTapped() {
        requestNotificationAuthorization()
    }
    
    @IBAction private func needHelpTapped() {
        showNeedHelpActionSheet()
    }

    private func requestNotificationAuthorization() {
        delegate?.requestPermission()
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
