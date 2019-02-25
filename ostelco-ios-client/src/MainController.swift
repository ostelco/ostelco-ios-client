//
//  MainController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/25/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class MainController: UIViewController {
    
    @IBAction func unwindFromLoginViewController(sender: UIStoryboardSegue) {
        perform(#selector(showSignUp), with: nil, afterDelay: 0)
    }
    
    @IBAction func unwindFromSignUpViewController(sender: UIStoryboardSegue) {
        perform(#selector(showCountry), with: nil, afterDelay: 0)
    }
    
    @IBAction func unwindFromCountryViewController(sender: UIStoryboardSegue) {
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
    
    @objc private func showLogin() {
        let viewController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController() as! LoginViewController2
        present(viewController, animated: true, completion: nil)
    }
    
    @objc private func showSignUp() {
        let viewController = UIStoryboard(name: "SignUp", bundle: nil).instantiateInitialViewController() as! SignUpViewController
        present(viewController, animated: true, completion: nil)
    }
    
    @objc private func showCountry() {
        let viewController = UIStoryboard(name: "Country", bundle: nil).instantiateInitialViewController() as! CountryViewController
        present(viewController, animated: true, completion: nil)
    }
    
    @objc private func showEKYC() {
        let viewController = UIStoryboard(name: "EKYC", bundle: nil).instantiateInitialViewController() as! EKYCViewController
        present(viewController, animated: true, completion: nil)
    }
    
    @objc private func showESim() {
        let viewController = UIStoryboard(name: "ESim", bundle: nil).instantiateInitialViewController() as! ESimViewController
        present(viewController, animated: true, completion: nil)
    }
    
    @objc private func showHome() {
        let viewController = UIStoryboard(name: "Home", bundle: nil).instantiateInitialViewController() as! HomeViewController2
        present(viewController, animated: true, completion: nil)
    }
    
}
