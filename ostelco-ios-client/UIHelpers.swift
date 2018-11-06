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
        self.addShadow(offset: CGSize(width: 0.0, height: 15.0), color: UIColor(red: 0, green: 68.0/255.0, blue: 166.0/255.0, alpha: 0.35), radius: 18.0, opacity: 1)
        self.backgroundColor = ThemeManager.currentTheme().mainColor
    }
}

class LaunchScreenViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        #if DEBUG
            self.imageView.image = UIImage(named: "StoryboardLaunchScreenDevelopment")!
        #else
            self.imageView.image = UIImage(named: "StoryboardLaunchScreenProduction")!
        #endif
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
