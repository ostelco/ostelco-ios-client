//
//  HomeViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/25/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import OstelcoStyles
import PromiseKit
import UIKit

import SwiftUI
import FacebookCore

class HomeViewController: UIViewController {

    private var newSubscriber = false
    public var handlePaymentSuccess: ((Product?) -> Void)!
    
    let buyText = NSLocalizedString("Buy Data", comment: "Primary action button on Home")
    let refreshBalanceText = NSLocalizedString("Updating data balance...", comment: "Loading text while determining data balance.")

    private lazy var byteCountFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter
    }()

    private func showToppedUpMessage() {
        /*
        welcomeLabel.text = NSLocalizedString("You have been topped up! 🎉", comment: "Success message when user buys more data.")
        messageLabel.text = NSLocalizedString("Thanks for using OYA", comment: "Thank you message when user buys more data")
        welcomeLabel.alpha = 1.0
        messageLabel.alpha = 1.0
        UIView.animate(
            withDuration: 2.0,
            delay: 2.0,
            options: .curveEaseIn,
            animations: {  [weak self] in
                self?.hideMessage()
            },
            completion: nil)
 */
    }

    private func hideMessage() {
        //welcomeLabel.alpha = 0.0
        //messageLabel.alpha = 0.0
    }

    deinit {
        // NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        embedSwiftUI(HomeView().environmentObject(HomeStore()))
    }

    @objc func didPullToRefresh() {
        hideMessage()
        // refreshBalance()
    }
}
