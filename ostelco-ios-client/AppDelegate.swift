//
//  AppDelegate.swift
//  ostelco-ios-client
//
//  Created by mac on 10/18/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import Auth0
import Stripe
import Firebase

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var myInfoDelegate: MyInfoCallbackHandler?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        STPPaymentConfiguration.shared().publishableKey = Environment().configuration(.StripePublishableKey)
        STPPaymentConfiguration.shared().appleMerchantIdentifier = Environment().configuration(.AppleMerchantId)
        #if DEBUG
            ThemeManager.applyTheme(theme: .TurquoiseTheme)
        #else
            ThemeManager.applyTheme(theme: .BlueTheme)
        #endif
      
        let freschatConfig:FreshchatConfig = FreshchatConfig.init(appID: Environment().configuration(.FreshchatAppID), andAppKey: Environment().configuration(.FreshchatAppKey))
        
        // freschatConfig.gallerySelectionEnabled = true; // set NO to disable picture selection for messaging via gallery
        // freschatConfig.cameraCaptureEnabled = true; // set NO to disable picture selection for messaging via camera
        // freschatConfig.teamMemberInfoVisible = true; // set to NO to turn off showing an team member avatar. To customize the avatar shown, use the theme file
        freschatConfig.showNotificationBanner = true; // set to NO if you don't want to show the in-app notification banner upon receiving a new message while the app is open
        
        Freshchat.sharedInstance().initWith(freschatConfig)
        
        FirebaseApp.configure()

        print("App started")
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
      print("URL = \(url.absoluteString)")
        return Auth0.resumeAuth(url, options: options)
    }
 
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Freshchat.sharedInstance().setPushRegistrationToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if Freshchat.sharedInstance().isFreshchatNotification(userInfo) {
            Freshchat.sharedInstance().handleRemoteNotification(userInfo, andAppstate: application.applicationState)
        }
    }
  func handleDynamicLink(dynamicLink: DynamicLink, incomingURL: URL) -> Bool {
    guard let url = dynamicLink.url else {
      print("No dynamic link object")
      return false
    }
    print("Incoming link = \(url.absoluteString)")
    // We can assume that this is an approved dynamic link.
    return handleMyInfoCallback(incomingURL)
  }

  func handleMyInfoCallback(_ url: URL) -> Bool {
    if let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
        myInfoDelegate?.handleCallback(queryItems: urlComponents.queryItems, error: nil)
        return true
    }
    return false
  }

  func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    if let incomingURL = userActivity.webpageURL {
      print("Incoming URL is \(incomingURL)")
      let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) {(dynamicLink, error) in
        guard error == nil else {
          print("Found an error \(error!.localizedDescription)")
          return
        }
        if let dynamicLink = dynamicLink {
          let handled = self.handleDynamicLink(dynamicLink: dynamicLink, incomingURL: incomingURL)
          print("handleDynamicLink ? = \(handled)")
        }
      }
      return linkHandled
    }
    return false
  }

}

protocol MyInfoCallbackHandler {
  func handleCallback(queryItems: [URLQueryItem]?, error: NSError?)
}
