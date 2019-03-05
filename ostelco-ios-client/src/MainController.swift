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
    
    @IBOutlet weak var notificationStatusLabel: UILabel!
    @IBOutlet weak var locationStatusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
            }
        } else {
            self.locationStatusLabel.text = "Location Status: Location Service is disabled"
        }
    }
    
    @IBAction func unwindFromLoginViewController(sender: UIStoryboardSegue) {
        // TODO: showSignUp is not called if delay is too small.
        // If you try to set afterDelay to 0, you will stay on the main screen and see the following warning in the logs:
        // Warning: Attempt to present <dev_ostelco_ios_client_app.TheLegalStuffViewController: 0x7fece3e24380> on <dev_ostelco_ios_client_app.MainController: 0x7fece38066d0> while a presentation is in progress!
        perform(#selector(showSignUp), with: nil, afterDelay: 0.5)
    }
    
    @IBAction func unwindFromSignUpViewController(sender: UIStoryboardSegue) {
        perform(#selector(showCountry), with: nil, afterDelay: 0)
    }
    
    @IBAction func unwindFromCountryViewController(sender: UIStoryboardSegue) {
        perform(#selector(showEKYC), with: nil, afterDelay: 0)
    }
    
    @IBAction func unwindFromCountry(sender: UIStoryboardSegue) {
        perform(#selector(showEKYC), with: nil, afterDelay: 0)
    }
    
    @IBAction func unwindFromEKYCViewController(sender: UIStoryboardSegue) {
        perform(#selector(showESim), with: nil, afterDelay: 0)
    }
    
    @IBAction func unwindFromESimViewController(sender: UIStoryboardSegue) {
        perform(#selector(showHome), with: nil, afterDelay: 0)
    }
    
    @IBAction func unwindFromHomeViewController(sender: UIStoryboardSegue) {
        
    }
    
    @IBAction func unwindFromSplashViewController(sender: UIStoryboardSegue) {
        perform(#selector(showLogin), with: nil, afterDelay: 0)
    }
    
    @IBAction func showLoginTapped(_ sender: Any?) {
        self.showLogin()
    }
    
    @IBAction func showSignUpTapped(_ sender: Any) {
        self.showSignUp()
    }
    
    @IBAction func showCountryTapped(_ sender: Any) {
        self.showCountry()
    }
    
    @IBAction func showEKYCTapped(_ sender: Any) {
        self.showEKYC()
    }
    
    @IBAction func showESimTapped(_ sender: Any) {
        self.showESim()
    }
    
    @IBAction func showHomeTapped(_ sender: Any) {
        self.showHome()
    }
    
    @IBAction func appStartTapped(_ sender: Any) {
        self.showSplash()
    }
    
    @objc private func showLogin() {
        let viewController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController() as! LoginViewController2
        self.presentVC(vc: viewController)
    }
    
    @objc private func showSignUp() {
        let viewController = UIStoryboard(name: "SignUp", bundle: nil).instantiateInitialViewController()!
        self.presentVC(vc: viewController)
    }
    
    @objc private func showCountry() {
        let viewController = UIStoryboard(name: "Country", bundle: nil).instantiateInitialViewController()!
        self.presentVC(vc: viewController)
    }
    
    @objc private func showEKYC() {
        let viewController = UIStoryboard(name: "EKYC", bundle: nil).instantiateInitialViewController() as! EKYCViewController
        self.presentVC(vc: viewController)
    }
    
    @objc private func showESim() {
        let viewController = UIStoryboard(name: "ESim", bundle: nil).instantiateInitialViewController() as! ESimViewController
        self.presentVC(vc: viewController)
    }
    
    @objc private func showHome() {
        let viewController = UIStoryboard(name: "Home", bundle: nil).instantiateInitialViewController() as! HomeViewController2
        self.presentVC(vc: viewController)
    }
    
    private func showSplash() {
        let viewController = UIStoryboard(name: "Splash", bundle: nil).instantiateInitialViewController() as! SplashViewController
        self.presentVC(vc: viewController)
    }
    
    private func presentVC(vc: UIViewController) {
        vc.modalTransitionStyle = .flipHorizontal
        present(vc, animated: true, completion: nil)
    }
}
