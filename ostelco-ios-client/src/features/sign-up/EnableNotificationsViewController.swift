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
    
    @IBAction func continueTapped(_ sender: Any) {
        self.enableNotifications()
    }
    
    private func showNotificationAlreadySetAlert(status: String) {
        let alert = UIAlertController(title: "Notification Alert", message: "your notification status is: \(status)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            DispatchQueue.main.async {
                self.showGetStarted()
            }
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func enableNotifications() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            switch (settings.authorizationStatus) {

            case .notDetermined:
                self.requestNotificationAuthorization()
            default:
                self.showNotificationAlreadySetAlert(status: settings.authorizationStatus.description)
            }
        }
    }
        
    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            DispatchQueue.main.async {
                self.showGetStarted()
            }
        }
    }
    
    private func showGetStarted() {
        performSegue(withIdentifier: "displayGetStarted", sender: self)
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
