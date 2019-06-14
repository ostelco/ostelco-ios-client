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

class HomeViewController: ApplePayViewController {

    static var newSubscriber = false

    var availableProducts: [Product] = []

    @IBOutlet private weak var balanceLabel: DataAmountOnHomeLabel!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var buyButton: UIButton!

    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var welcomeLabel: UILabel!

    let unlockText = "Unlock More Data"
    let buyText = "Buy Data"
    let refreshBalanceText = "Updating data balance..."

    private lazy var refreshControl = UIRefreshControl()
    var hasSubscription = false {
        didSet {
            buyButton.setTitle(
                (hasSubscription == false) ? unlockText : buyText,
                for: .normal
            )
            if hasSubscription {
                showWelcomeMessage()
            }
        }
    }
    
    private lazy var byteCountFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter
    }()

    private func showMessage() {
        welcomeLabel.alpha = 1.0
        messageLabel.alpha = 1.0
        UIView.animate(
            withDuration: 2.0,
            delay: 2.0,
            options: .curveEaseIn,
            animations: {  [weak self] in
                self?.hideMessages()
            },
            completion: nil)
    }

    private func hideMessages() {
        welcomeLabel.alpha = 0.0
        messageLabel.alpha = 0.0
    }

    private func showWelcomeMessage() {
        if HomeViewController.newSubscriber {
            HomeViewController.newSubscriber = false
            showMessage()
        }
    }

    private func showToppedUpMessage() {
        welcomeLabel.text = "You have been topped up! 🎉"
        messageLabel.text = "Thanks for using OYA"
        showMessage()
    }

    private func checkForSubscription(_ products: [Product]) -> Bool {
        // See if the list contains offers.
        // TODO: Changes needed to support global app.
        let hasOffers = products.contains { $0.type != "membership" }
        // If we have offers, user is already a member
        return hasOffers
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.registerForPushNotificationsIfNeeded()
        self.balanceLabel.dataAmountString = nil

        scrollView.alwaysBounceVertical = true
        scrollView.bounces = true
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        refreshControl.attributedTitle = NSMutableAttributedString(string: refreshBalanceText)
        self.scrollView.addSubview(refreshControl)
        refreshBalance()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchProducts()
    }
    
    private func registerForPushNotificationsIfNeeded() {
        PushNotificationController.shared.checkSettingsThenRegisterForNotifications(authorizeIfNotDetermined: true)
            .catch { error in
                switch error {
                case PushNotificationController.Error.notAuthorized:
                    // This is an expected error type, we don't need to do anything.
                    break
                default:
                    ApplicationErrors.log(error)
                }
            }
    }

    private func fetchProducts() {
        getProducts()
            .done { [weak self] products in
                products.forEach { debugPrint($0) }
                guard let self = self else {
                    return
                }
                
                self.availableProducts = products
                // Check if the customer is a member already.
                self.hasSubscription = self.checkForSubscription(products)
                debugPrint("User has subscription ? \(self.hasSubscription)")
            }
            .catch { error in
                ApplicationErrors.log(error)
            }
    }

    override func paymentSuccessful(_ product: Product?) {
        refreshBalance()
        showToppedUpMessage()
    }

    func refreshBalance() {
        // Call the bundles API
        APIManager.shared.primeAPI
            .loadBundles()
            .ensure { [weak self] in
                self?.refreshControl.endRefreshing()
            }
            .done { [weak self] bundles in
                debugPrint(bundles)
                self?.updateBalance(from: bundles)
            }
            .catch { error in
                ApplicationErrors.log(error)
        }
    }

    @objc func didPullToRefresh() {
        hideMessages()
        refreshBalance()
    }

    @IBAction private func buyDataTapped(_ sender: Any) {
        if hasSubscription {
            // TODO: Should we show the plans here ?
            showProductListActionSheet(products: self.availableProducts)
        } else {
            performSegue(withIdentifier: "becomeMember", sender: self)
        }
    }

    private func updateBalance(from bundles: [BundleModel]) {
        guard let bundle = bundles.first else {
            return
        }
        
        let formattedBalance = self.byteCountFormatter.string(fromByteCount: bundle.balance)
        self.balanceLabel.dataAmountString = formattedBalance
    }
    
    private func showProductListActionSheet(products: [Product]) {
        let alertCtrl = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for product in products {
            let buyAction = UIAlertAction(title: product.label, style: .default) {_ in
                #if STRIPE_PAYMENT
                    self.startStripePay(product: product)
                #else
                    self.startApplePay(product: product)
                #endif
            }
            alertCtrl.addAction(buyAction)
        }
        #if STRIPE_PAYMENT
            let addCardsAction = UIAlertAction(title: "Setup Cards", style: .default) {_ in
                self.showPaymentOptions()
            }
            alertCtrl.addAction(addCardsAction)
        #endif
        
        alertCtrl.addAction(.cancelAction())
        self.presentActionSheet(alertCtrl)
    }
}
