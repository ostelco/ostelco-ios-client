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

    }
    
    @IBAction func unwindFromSignUpViewController(sender: UIStoryboardSegue) {
        
    }
    
    @IBAction func unwindFromCountryViewController(sender: UIStoryboardSegue) {
        
    }
    
    @IBAction func unwindFromEKYCViewController(sender: UIStoryboardSegue) {
        
    }
    
    @IBAction func unwindFromESimViewController(sender: UIStoryboardSegue) {
        
    }
    
    @IBAction func unwindFromHomeViewController(sender: UIStoryboardSegue) {
        
    }
    
    @IBAction func showLoginViewController(_ sender: Any) {
        print("Ssow Login View Controller")
        let viewController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController() as! LoginViewController2
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func showSignUpViewController(_ sender: Any) {
        let viewController = UIStoryboard(name: "SignUp", bundle: nil).instantiateInitialViewController() as! SignUpViewController
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func showCountryViewController(_ sender: Any) {
        let viewController = UIStoryboard(name: "Country", bundle: nil).instantiateInitialViewController() as! CountryViewController
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func showEKYCViewController(_ sender: Any) {
        let viewController = UIStoryboard(name: "EKYC", bundle: nil).instantiateInitialViewController() as! EKYCViewController
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func showESimViewController(_ sender: Any) {
        let viewController = UIStoryboard(name: "ESim", bundle: nil).instantiateInitialViewController() as! ESimViewController
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func showHomeViewController(_ sender: Any) {
        let viewController = UIStoryboard(name: "Home", bundle: nil).instantiateInitialViewController() as! HomeViewController2
        present(viewController, animated: true, completion: nil)
    }
    
}
