//
//  UIHelpers.swift
//  ostelco-ios-client
//
//  Created by mac on 10/21/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit

extension UIView {
    
    func addShadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
        layer.masksToBounds = false
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        
        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor = nil
        layer.backgroundColor =  backgroundCGColor
    }
}

extension UIViewController {
    class func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    class func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
    
    func showAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}

class TopUpButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 22.5
        self.addShadow(offset: CGSize(width: 0.0, height: 15.0), color: ThemeManager.currentTheme().mainColor.withAlphaComponent(0.35), radius: 18.0, opacity: 1)
        self.backgroundColor = ThemeManager.currentTheme().mainColor
    }
}

class SignInWithEmailButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 30
        self.addShadow(offset: CGSize(width: 0.0, height: 15.0), color: ThemeManager.currentTheme().mainColor.withAlphaComponent(0.35), radius: 18.0, opacity: 1)
        self.setTitleColor(ThemeManager.currentTheme().textOnMainColor, for: .normal)
        self.setTitle("Sign in with email", for: .normal)
        self.backgroundColor = ThemeManager.currentTheme().mainColor
        let emailImage = UIImage(named: "email")?.tint(with: ThemeManager.currentTheme().textOnMainColor)
        self.setImage(emailImage, for: .normal)        
    }
}

class LogoImageView: UIImageView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.contentMode = .scaleAspectFit;
        self.image = ThemeManager.currentTheme().logo
    }
}

class LaunchScreenViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        if let bundleIndentifier = Bundle.main.bundleIdentifier {
            if bundleIndentifier.contains("dev") {
                self.imageView.image = UIImage(named: "StoryboardLaunchScreenDevelopment")!
            } else {
                self.imageView.image = UIImage(named: "StoryboardLaunchScreenProduction")!
            }
        } else {
            self.imageView.image = UIImage(named: "StoryboardLaunchScreenDevelopment")!
        }
    }
}

extension UIScrollView {
    
    // Exposes a _refreshControl property to iOS versions anterior to iOS 10
    // Use _refreshControl and refreshControl intercheangeably in a UIScrollView (get + set)
    //
    // All iOS versions: `bounces` is always required if `contentSize` is smaller than `frame`
    // Pre iOS 10 versions: `alwaysBounceVertical` is also required for small content
    // Only iOS 10 allows the refreshControl to work without drifting when pulled to refresh
    var _refreshControl : UIRefreshControl? {
        get {
            if #available(iOS 10.0, *) {
                return refreshControl
            } else {
                return subviews.first(where: { (view: UIView) -> Bool in
                    view is UIRefreshControl
                }) as? UIRefreshControl
            }
        }
        
        set {
            if #available(iOS 10.0, *) {
                refreshControl = newValue
            } else {
                // Unique instance of UIRefreshControl added to subviews
                if let oldValue = _refreshControl {
                    oldValue.removeFromSuperview()
                }
                if let newValue = newValue {
                    insertSubview(newValue, at: 0)
                }
            }
        }
    }
    
    // Creates and adds a UIRefreshControl to this UIScrollView
    func addRefreshControl(target: Any?, action: Selector) -> UIRefreshControl {
        let control = UIRefreshControl()
        addRefresh(control: control, target: target, action: action)
        return control
    }
    
    // Adds the UIRefreshControl passed as parameter to this UIScrollView
    func addRefresh(control: UIRefreshControl, target: Any?, action: Selector) {
        if #available(iOS 9.0, *) {
            control.addTarget(target, action: action, for: .primaryActionTriggered)
        } else {
            control.addTarget(target, action: action, for: .valueChanged)
        }
        _refreshControl = control
    }
}

extension UIColor {
    
    // MARK: - Initialization
    
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt32 = 0
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        
        let length = hexSanitized.count
        
        guard Scanner(string: hexSanitized).scanHexInt32(&rgb) else { return nil }
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
            
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    // MARK: - Computed Properties
    
    var toHex: String? {
        return toHex()
    }
    
    // MARK: - From UIColor to String
    
    func toHex(alpha: Bool = false) -> String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)
        
        if components.count >= 4 {
            a = Float(components[3])
        }
        
        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
    
}

public extension UIImage {
    
    //
    /// Tint Image
    ///
    /// - Parameter fillColor: UIColor
    /// - Returns: Image with tint color
    func tint(with fillColor: UIColor) -> UIImage? {
        let image = withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        fillColor.set()
        image.draw(in: CGRect(origin: .zero, size: size))
        
        guard let imageColored = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        
        UIGraphicsEndImageContext()
        return imageColored
    }
}

import os

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name(FRESHCHAT_UNREAD_MESSAGE_COUNT_CHANGED), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Freshchat.sharedInstance().unreadCount { (unreadCount) in
            self.updateBadgeCount(count: unreadCount)
        }
    }
    
    @objc func methodOfReceivedNotification(notification: Notification){
        Freshchat.sharedInstance().unreadCount { (count:Int) -> Void in
            self.updateBadgeCount(count: count)
        }
    }
    
    func updateBadgeCount(count: Int) {
        if let tabItems = tabBar.items {
            if count > 0 {
                tabItems[1].badgeValue = "\(count)"
            } else {
                tabItems[1].badgeValue = nil
            }
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController,
                          shouldSelect viewController: UIViewController) -> Bool {
        Freshchat.sharedInstance().unreadCount { (unreadCount) in
            self.updateBadgeCount(count: unreadCount)
        }
        if tabBarController.viewControllers!.firstIndex(of: viewController) == 1 {
            updateBadgeCount(count: 0)
            Freshchat.sharedInstance().showConversations(self)
            return false
        }
        return true
    }
}
