//
//  AccountStore.swift
//  ostelco-ios-client
//
//  Created by mac on 10/18/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Combine

final class AccountStore: ObservableObject {
    @Published public var purchaseRecords: [PurchaseRecord] = []
    @Published public var unreadMessages: Int = 0
    
    private let controller: UIViewController
    
    init(controller: UIViewController) {
        self.controller = controller
        
        updateUnreadMessagesCount()
        NotificationCenter.default.addObserver(self, selector: #selector(unreadMessagesCountChanged(_:)), name: Notification.Name(FRESHCHAT_UNREAD_MESSAGE_COUNT_CHANGED), object: nil)
        
        APIManager.shared.primeAPI.loadPurchases()
        .map { purchaseModels -> [PurchaseRecord] in
            let sortedPurchases = purchaseModels.sorted { $0.timestamp > $1.timestamp }
            return sortedPurchases.map { PurchaseRecord(from: $0) }
        }
        .done {
            self.purchaseRecords = $0
        }
        .catch { error in
            ApplicationErrors.log(error)
            // TODO: Notify user about this error.
        }
    }
    
    @objc private func unreadMessagesCountChanged(_ notification: NSNotification) {
        updateUnreadMessagesCount()
    }
    
    private func updateUnreadMessagesCount() {
        Freshchat.sharedInstance()?.unreadCount {
            self.unreadMessages = $0
        }
    }
}
