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

protocol MyInfoCallbackHandler: class {
    func handleCallback(queryItems: [URLQueryItem]?, error: NSError?)
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    weak var myInfoDelegate: MyInfoCallbackHandler?
    var fcmToken: String?
    
    private(set) lazy var rootCoordinator: RootCoordinator = {
        guard let window = self.window else {
            fatalError("No window?!")
        }
        
        return RootCoordinator(window: window)
    }()
    
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
        // freschatConfig.gallerySelectionEnabled = true; // set NO to disable picture selection for messaging via gallery
        // freschatConfig.cameraCaptureEnabled = true; // set NO to disable picture selection for messaging via camera
        // freschatConfig.teamMemberInfoVisible = true; // set to NO to turn off showing an team member avatar. To customize the avatar shown, use the theme file
        freschatConfig.showNotificationBanner = true; // set to NO if you don't want to show the in-app notification banner upon receiving a new message while the app is open
        Freshchat.sharedInstance().initWith(freschatConfig)
        
        application.applicationSupportsShakeToEdit = true
        
        self.registerForNotifications()
        InternetConnectionMonitor.shared.start()

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
        if
            let bundleIndentifier = Bundle.main.bundleIdentifier,
            bundleIndentifier.contains("dev") {
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
            myInfoDelegate?.handleCallback(queryItems: urlComponents.queryItems, error: nil)
            return true
        }
        return false
    }
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard let incomingURL = userActivity.webpageURL else {
            return false
        }
        
        debugPrint("Incoming URL is \(incomingURL)")
        
        if EmailLinkManager.isSignInLink(incomingURL) {
            EmailLinkManager.signInWithLink(incomingURL)
                .then {
                    UserManager.shared.getDestinationFromContext()
                }
                .done { [weak self] destination in
                    self?.rootCoordinator.navigate(to: destination, from: nil)
                }
                .catch { error in
                    ApplicationErrors.log(error)
                    debugPrint("ERROR SIGNING IN: \(error)")
                }
            
            // Even though this other stuff is async, we can definitely say we've hadnled it.
            return true
        }
        
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
    
    // MARK: - UIResponder overrides
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        
        switch motion {
        case .motionShake:
            guard let vc = self.window?.rootViewController else {
                // There's no view controller to show.
                return
            }
            
            if let nav = vc as? UINavigationController {
                nav.showNeedHelpActionSheet()
            } else if let tab = vc as? UITabBarController {
                tab.showNeedHelpActionSheet()
            } else {
                vc.topPresentedViewController().showNeedHelpActionSheet()
            }
        default:
            break
        }
    }
}
