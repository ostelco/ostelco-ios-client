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
        enableNotifications(ignoreNotDetermined: true)
    }
    
    @IBAction func continueTapped(_ sender: Any) {
        enableNotifications()
    }

    @IBAction func dontAllowTapped(_ sender: Any) {
        enableNotifications()
    }
    @IBAction func okTapped(_ sender: Any) {
        enableNotifications()
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

    private func registerAndContinue() {
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.enableNotifications()
            self.showGetStarted()
        }
    }

    private func enableNotifications(ignoreNotDetermined: Bool = false) {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            switch (settings.authorizationStatus) {
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

    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            self.registerAndContinue()
        }
    }

    private func showGetStarted() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "displayGetStarted", sender: self)
        }
    }
}
