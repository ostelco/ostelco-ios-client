//
//  RootViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 11/9/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation
import UIKit
import Bugsee

class RootViewController: UIViewController {
    private var current: UIViewController
    
    init() {
        self.current = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "splashvc") as! SplashScreenViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.current = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "splashvc") as! SplashScreenViewController
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        sharedAuth.verifyCredentials(completion: {_ in})
        
        addChild(current)
        current.view.frame = view.bounds
        view.addSubview(current.view)
        current.didMove(toParent: self)
    }
    
    func showLoginScreen() {
        let new = UINavigationController(rootViewController: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginvc") as! LoginViewController)
        
        addChild(new)
        new.view.frame = view.bounds
        view.addSubview(new.view)
        new.didMove(toParent: self)
        
        current.willMove(toParent: nil)
        current.view.removeFromSuperview()
        current.removeFromParent()
        
        current = new
    }
    
    func switchToMainScreen() {
        DispatchQueue.main.async {
            let mainViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabbarvc") as! UITabBarController
            let mainScreen = UINavigationController(rootViewController: mainViewController)
            self.animateFadeTransition(to: mainScreen)
        }
    }
    
    func switchToLogout() {
        DispatchQueue.main.async {
            let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginvc") as! LoginViewController
            let logoutScreen = UINavigationController(rootViewController: loginViewController)
            self.animateDismissTransition(to: logoutScreen)
        }
    }
    
    private func animateFadeTransition(to new: UIViewController, completion: (() -> Void)? = nil) {
        current.willMove(toParent: nil)
        addChild(new)
        
        transition(from: current, to: new, duration: 0.3, options: [.transitionCrossDissolve, .curveEaseIn], animations: {
            
        }) { completed in
            self.current.removeFromParent()
            new.didMove(toParent: self)
            self.current = new
            completion?()
        }
    }
    
    private func animateDismissTransition(to new: UIViewController, completion: (() -> Void)? = nil) {
        let initialFrame = CGRect(x: -view.bounds.width, y: 0, width: view.bounds.width, height: view.bounds.height)
        current.willMove(toParent: nil)
        addChild(new)
        
        transition(from: current, to: new, duration: 0.3, options: [], animations: {
            new.view.frame = self.view.bounds
        }) { completed in
            self.current.removeFromParent()
            new.didMove(toParent: self)
            self.current = new
            completion?()
        }
    }
}

extension AppDelegate {
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    var rootViewController: RootViewController {
        return window!.rootViewController as! RootViewController
    }
}
