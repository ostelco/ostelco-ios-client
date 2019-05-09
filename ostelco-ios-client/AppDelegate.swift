//
//  AppDelegate.swift
//  ostelco-ios-client
//
//  Created by mac on 10/18/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import Stripe
import Firebase
import ostelco_core
import PromiseKit
import Siesta
import UserNotifications

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    weak var myInfoDelegate: MyInfoCallbackHandler?
    let gcmMessageIDKey = "gcm.message_id"
    var fcmToken: String?
    
    private(set) lazy var rootCoordinator: RootCoordinator = {
        guard let window = self.window else {
            fatalError("No window?!")
        }
        
        return RootCoordinator(window: window)
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        STPPaymentConfiguration.shared().publishableKey = Environment().configuration(.StripePublishableKey)
        STPPaymentConfiguration.shared().appleMerchantIdentifier = Environment().configuration(.AppleMerchantId)
        if let bundleIndentifier = Bundle.main.bundleIdentifier {
            if bundleIndentifier.contains("dev") {
                ThemeManager.applyTheme(theme: .TurquoiseTheme)
                SiestaLog.Category.enabled = .all
            } else {
                ThemeManager.applyTheme(theme: .BlueTheme)
            }
        } else {
            ThemeManager.applyTheme(theme: .TurquoiseTheme)
            SiestaLog.Category.enabled = .all
        }
        
        let freschatConfig: FreshchatConfig = FreshchatConfig(appID: Environment().configuration(.FreshchatAppID), andAppKey: Environment().configuration(.FreshchatAppKey))
        // freschatConfig.gallerySelectionEnabled = true; // set NO to disable picture selection for messaging via gallery
        // freschatConfig.cameraCaptureEnabled = true; // set NO to disable picture selection for messaging via camera
        // freschatConfig.teamMemberInfoVisible = true; // set to NO to turn off showing an team member avatar. To customize the avatar shown, use the theme file
        freschatConfig.showNotificationBanner = true; // set to NO if you don't want to show the in-app notification banner upon receiving a new message while the app is open
        Freshchat.sharedInstance().initWith(freschatConfig)
        
        application.applicationSupportsShakeToEdit = true
        
        registerNotifications(authorise: false)
        FirebaseApp.configure()

        print("App started")
        
        return true
    }
    
    func enableNotifications() {
        DispatchQueue.main.async {
            print("Registering for RemoteNotifications")
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            UIApplication.shared.registerForRemoteNotifications()
            Messaging.messaging().delegate = self
        }
    }
    
    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, _) in
            DispatchQueue.main.async {
                if granted {
                    self.enableNotifications()
                }
            }
        }
    }
    
    func registerNotifications(authorise: Bool) {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notifications Status: \(settings.authorizationStatus.rawValue)")
            switch settings.authorizationStatus {
            case .notDetermined:
                if authorise == true {
                    self.requestNotificationAuthorization()
                }
            case.authorized:
                self.enableNotifications()
            default:
                print("Notifications not enabled. Status: \(settings.authorizationStatus)")
            }
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
        guard let incomingURL = userActivity.webpageURL else {
            return false
        }
        
        debugPrint("Incoming URL is \(incomingURL)")
        
        if EmailLinkManager.isSignInLink(incomingURL) {
            EmailLinkManager.signInWithLink(incomingURL)
                .then {
                    UserManager.sharedInstance.getDestinationFromContext()
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
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        
        print("Function: \(#function), line: \(#line)")
        
        // Handle  Handle data of notification (The ones not handled by
        if Freshchat.sharedInstance().isFreshchatNotification(userInfo) {
            Freshchat.sharedInstance().handleRemoteNotification(userInfo, andAppstate: application.applicationState)
        }
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        print("Function: \(#function), line: \(#line)")
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Function: \(#function), line: \(#line)")
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Function: \(#function), line: \(#line)")
        print("APNs token retrieved: \(deviceToken)")
        Freshchat.sharedInstance().setPushRegistrationToken(deviceToken)
        
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }
}

protocol MyInfoCallbackHandler: class {
    func handleCallback(queryItems: [URLQueryItem]?, error: NSError?)
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Function: \(#function), line: \(#line)")
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        sendDidReceivePushNotification(userInfo)
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Function: \(#function), line: \(#line)")
        
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        sendDidReceivePushNotification(userInfo)
        completionHandler()
    }
    
    func sendDidReceivePushNotification(_ userInfo: [AnyHashable: Any]) {
        NotificationCenter.default.post(name: .didReceivePushNotification, object: self, userInfo: userInfo)
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Function: \(#function), line: \(#line)")
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict: [String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        // Send token to prime.
        self.fcmToken = fcmToken
        sendFCMToken()
    }
    
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Function: \(#function), line: \(#line)")
        print("Received data message: \(remoteMessage.appData)")
    }
    
    func sendFCMToken() {
        guard
            UserManager.sharedInstance.firebaseUser != nil,
            let token = fcmToken else {
                // Wait to be authenticated, or the token to be ready.
                return
        }
        
        // Use the application ID as <BundleId>.<Unique DeviceID or UUID>
        let appId = "\(Bundle.main.bundleIdentifier!).\(UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString)"
        
        let pushToken = PushToken(token: token, applicationID: appId)
        APIManager.sharedInstance.loggedInAPI.sendPushToken(pushToken)
            .done {
                debugPrint("Set new FCM token: \(token)")
            }
            .catch { error in
                ApplicationErrors.log(error)
            }
    }
    
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
