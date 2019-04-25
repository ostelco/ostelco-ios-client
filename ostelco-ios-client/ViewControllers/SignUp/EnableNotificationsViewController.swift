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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.enableNotifications(ignoreNotDetermined: true)
    }
    
    private func registerAndContinue() {
        UIApplication.shared.typedDelegate.enableNotifications()
        self.showGetStarted()
    }
    
    private func enableNotifications(ignoreNotDetermined: Bool = false) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    if !ignoreNotDetermined {
                        self.requestNotificationAuthorization()
                    }
                case.authorized:
                    print("Already authorized to show notifications, continue")
                    self.registerAndContinue()
                default:
                    self.showGetStarted()
                }
            }
        }
    }
    
    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
            DispatchQueue.main.async {
                self.registerAndContinue()
            }
        }
    }
    
    private func showGetStarted() {
        self.performSegue(withIdentifier: "displayGetStarted", sender: self)
    }
}
