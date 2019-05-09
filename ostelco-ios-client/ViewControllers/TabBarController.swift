//
//  TabBarController.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/8/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name(FRESHCHAT_UNREAD_MESSAGE_COUNT_CHANGED), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Freshchat.sharedInstance().unreadCount { (unreadCount) in
            self.updateBadgeCount(to: unreadCount)
        }
    }
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        Freshchat.sharedInstance().unreadCount { (count: Int) -> Void in
            self.updateBadgeCount(to: count)
        }
    }
    
    func updateBadgeCount(to badgeCount: Int) {
        if let tabItems = tabBar.items {
            if badgeCount > 0 {
                tabItems[1].badgeValue = "\(badgeCount)"
            } else {
                tabItems[1].badgeValue = nil
            }
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController,
                          shouldSelect viewController: UIViewController) -> Bool {
        Freshchat.sharedInstance().unreadCount { (unreadCount) in
            self.updateBadgeCount(to: unreadCount)
        }
        if tabBarController.viewControllers!.firstIndex(of: viewController) == 1 {
            updateBadgeCount(to: 0)
            Freshchat.sharedInstance().showConversations(self)
            return false
        }
        return true
    }
}

extension TabBarController: StoryboardLoadable {
    
    static var storyboard: Storyboard {
        return .tabController
    }
    
    static var isInitialViewController: Bool {
        return true
    }
}
