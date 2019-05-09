//
//  TestAppDelegate.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/8/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Firebase

class TestAppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        let vc = UIViewController()
        vc.view.backgroundColor = .orange
        
        let label = UILabel()
        label.text = "TESTING WITHOUT UI!"
        label.textColor = .white
        
        vc.view.addSubview(label)
        label.center = vc.view.center
        
        let window = UIWindow()
        window.rootViewController = vc
        
        window.makeKeyAndVisible()
        self.window = window
        
        return true
    }
}
