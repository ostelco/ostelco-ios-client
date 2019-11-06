//
//  main.swift
//  ostelco-ios-client
//
//  Created by mac on 3/14/19.
//  Copyright © 2019 mac. All rights reserved.
//

let appDelegateClassName: String

if UIApplication.isNonUITesting {
    // Launch using test app delegate to prevent state from spinning up
    appDelegateClassName = NSStringFromClass(TestAppDelegate.self)
} else {
    appDelegateClassName = NSStringFromClass(AppDelegate.self)
}

_ = UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, appDelegateClassName)
 
