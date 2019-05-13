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

    private func showWelcomeMessage() {
        if HomeViewController.newSubscriber {
            welcomeLabel.isHidden = false
            messageLabel.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.welcomeLabel.isHidden = true
                self?.messageLabel.isHidden = true
            }
        }
    }

    private func checkForSubscription(_ products: [Product]) -> Bool {
        // See if the list contains offers.
        // TODO: Changes needed to support global app.
        let hasOffers = products.contains { $0.type != "plan" && $0.currency.lowercased() == "sgd" }
        // If we have offers, user is already a member
        return hasOffers
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.typedDelegate.registerNotifications(authorise: true)

        scrollView.alwaysBounceVertical = true
        scrollView.bounces = true
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        refreshControl.attributedTitle = NSMutableAttributedString(string: refreshBalanceText)
        self.scrollView.addSubview(refreshControl)
        refreshControl.beginRefreshing()
        didPullToRefresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchProducts()
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
                debugPrint("error fetching products \(error)")
            }
    }

    override func paymentSuccessful(_ product: Product?) {
        refreshControl.beginRefreshing()
        didPullToRefresh()
    }

    @objc func didPullToRefresh() {
        // Hide the Message on top
        welcomeLabel.isHidden = true
        messageLabel.isHidden = true
        
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
        self.balanceLabel.text = formattedBalance
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
        present(alertCtrl, animated: true, completion: nil)
    }
}
