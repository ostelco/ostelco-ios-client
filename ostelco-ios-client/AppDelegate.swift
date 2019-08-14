//
//  AppDelegate.swift
//  ostelco-ios-client
//
//  Created by mac on 10/18/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Firebase
import FirebaseDynamicLinks
import ostelco_core
import OstelcoStyles
import PromiseKit
import Stripe
import UIKit

let MyInfoNotification: Notification.Name = Notification.Name(rawValue: "MyInfoNotification")

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var fcmToken: String?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
    
        STPPaymentConfiguration.shared().publishableKey = Environment().configuration(.StripePublishableKey)
        #if STRIPE_PAYMENT
            debugPrint("Stripe Payment enabled")
        #else
            STPPaymentConfiguration.shared().appleMerchantIdentifier = Environment().configuration(.AppleMerchantId)
        #endif
        
        self.configureAppearance()
        
        let freschatConfig: FreshchatConfig = FreshchatConfig(appID: Environment().configuration(.FreshchatAppID), andAppKey: Environment().configuration(.FreshchatAppKey))
        freschatConfig.domain = "msdk.eu.freshchat.com"
        // freschatConfig.gallerySelectionEnabled = true; // set NO to disable picture selection for messaging via gallery
        // freschatConfig.cameraCaptureEnabled = true; // set NO to disable picture selection for messaging via camera
        // freschatConfig.teamMemberInfoVisible = true; // set to NO to turn off showing an team member avatar. To customize the avatar shown, use the theme file
        freschatConfig.showNotificationBanner = true; // set to NO if you don't want to show the in-app notification banner upon receiving a new message while the app is open
        Freshchat.sharedInstance().initWith(freschatConfig)
        
        application.applicationSupportsShakeToEdit = true
        
        self.registerForNotifications()

        return true
    }
    
    private func registerForNotifications() {
        PushNotificationController.shared.checkSettingsThenRegisterForNotifications(authorizeIfNotDetermined: false)
            .done { registered in
                if registered {
                    debugPrint("Registered for notifications!")
                } // else, we'll ask again later.
            }
            .catch { error in
                switch error {
                case PushNotificationController.Error.notAuthorized(let status):
                    debugPrint("User cannot register for notifications. Status: \(status.description)")
                default:
                    // This is some other kind of error we weren't expecting.
                    ApplicationErrors.log(error)
                }
            }
    }
    
    private func configureAppearance() {
        if let bundleIndentifier = Bundle.main.bundleIdentifier, bundleIndentifier.contains("dev") {
            OstelcoColor.useDevColor = true
        }
        
        let mainColor = OstelcoColor.oyaBlue.toUIColor
        UITabBar.appearance().tintColor = mainColor
        UIToolbar.appearance().tintColor = mainColor
        UINavigationBar.appearance().tintColor = mainColor
    }
    
    // MARK: - Deeplink Handling
    
    private func handleDynamicLink(dynamicLink: DynamicLink, incomingURL: URL) -> Bool {
        guard let url = dynamicLink.url else {
            print("No dynamic link object")
            return false
        }
        print("Incoming link = \(url.absoluteString)")
        // We can assume that this is an approved dynamic link.
        return handleMyInfoCallback(incomingURL)
    }
    
    private func handleMyInfoCallback(_ url: URL) -> Bool {
        if let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            NotificationCenter.default.post(name: MyInfoNotification, object: urlComponents.queryItems)
            return true
        }
        return false
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard let incomingURL = userActivity.webpageURL else {
            return false
        }
        
        debugPrint("Incoming URL is \(incomingURL)")
        
        // If we've gotten here, it's some other kind of universal link.
        return DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { dynamicLink, error in
            guard error == nil else {
                print("Found an error \(error!.localizedDescription)")
                return
            }
            if let dynamicLink = dynamicLink {
                let handled = self.handleDynamicLink(dynamicLink: dynamicLink, incomingURL: incomingURL)
                print("handleDynamicLink ? = \(handled)")
            }
        }
    }
    
    // MARK: - Notification handling
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        PushNotificationController.shared.application(application, didReceiveRemoteNotification: userInfo)
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        PushNotificationController.shared.application(application,
                                                      didReceiveRemoteNotification: userInfo,
                                                      fetchCompletionHandler: completionHandler)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        PushNotificationController.shared.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PushNotificationController.shared.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
}
