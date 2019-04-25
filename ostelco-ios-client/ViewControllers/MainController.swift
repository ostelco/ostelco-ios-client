//
//  MainController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/25/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import UserNotifications
import CoreLocation

class MainController: UIViewController {
    
    @IBOutlet private weak var notificationStatusLabel: UILabel!
    @IBOutlet private weak var locationStatusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkNotificationStatus()
        checkLocationStatus()
    }
    
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            DispatchQueue.main.async {
                self.notificationStatusLabel.text = "Notification Status: \(settings.authorizationStatus.description)"
            }
        }
    }
    
    private func checkLocationStatus() {
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            switch status {
            case .notDetermined:
                self.locationStatusLabel.text = "Location Status: Not Determined"
            case .restricted:
                self.locationStatusLabel.text = "Location Status: Restricted"
            case .denied:
                self.locationStatusLabel.text = "Location Status: Denied"
            case .authorizedAlways:
                self.locationStatusLabel.text = "Location Status: Always"
            case .authorizedWhenInUse:
                self.locationStatusLabel.text = "Location Status: When In Use"
            @unknown default:
                assertionFailure("Apple added something! You should update the handling code here.")
            }
        } else {
            self.locationStatusLabel.text = "Location Status: Location Service is disabled"
        }
    }
    
    @IBAction private func unwindFromCountryViewController(sender: UIStoryboardSegue) {
        // perform(#selector(showEKYC), with: nil, afterDelay: 0)
    }
    
    @IBAction private func unwindFromCountry(sender: UIStoryboardSegue) {
        // perform(#selector(showEKYC), with: nil, afterDelay: 0)
    }
    
    @IBAction private func unwindFromEKYCViewController(sender: UIStoryboardSegue) {
        // perform(#selector(showESim), with: nil, afterDelay: 0)
    }
    
    @IBAction private func unwindFromESimViewController(sender: UIStoryboardSegue) {
        // perform(#selector(showHome), with: nil, afterDelay: 0)
    }
    
    @IBAction private func unwindFromHomeViewController(sender: UIStoryboardSegue) {
        
    }
    
    @IBAction private func unwindFromSplashViewController(sender: UIStoryboardSegue) {
        // perform(#selector(showLogin), with: nil, afterDelay: 0)
    }
    
    @IBAction private func showLoginTapped(_ sender: Any?) {
        self.showLogin()
    }
    
    @IBAction private func showEKYCTapped(_ sender: Any) {
        self.showEKYC()
    }
    
    @IBAction private func showESimTapped(_ sender: Any) {
        self.showESim()
    }
    
    @IBAction private func showHomeTapped(_ sender: Any) {
        self.showHome()
    }
    
    @IBAction private func appStartTapped(_ sender: Any) {
        self.showSplash()
    }
    
    @objc private func showLogin() {
        let viewController: LoginViewController = Storyboard.login.initialViewController()
        self.presentVC(vc: viewController)
    }
    
    @objc private func showEKYC() {
        let viewController = Storyboard.ekyc.asUIStoryboard.instantiateInitialViewController()!
        self.presentVC(vc: viewController)
    }
    
    @objc private func showESim() {
        let viewController = Storyboard.esim.asUIStoryboard.instantiateInitialViewController()!
        self.presentVC(vc: viewController)
    }
    
    @objc private func showHome() {
        let viewController = Storyboard.home.asUIStoryboard.instantiateInitialViewController()!
        self.presentVC(vc: viewController)
    }
    
    private func showSplash() {
        let viewController: SplashViewController = Storyboard.splash.initialViewController()
        self.presentVC(vc: viewController)
    }
    
    private func presentVC(vc: UIViewController) {
        vc.modalTransitionStyle = .flipHorizontal
        present(vc, animated: true, completion: nil)
    }
}
