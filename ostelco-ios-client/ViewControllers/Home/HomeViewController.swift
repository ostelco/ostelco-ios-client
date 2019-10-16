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
import FacebookCore

class HomeViewController: ApplePayViewController {

    private var newSubscriber = false

    var availableProducts: [Product] = []

    @IBOutlet private weak var balanceLabel: DataAmountOnHomeLabel!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var buyButton: UIButton!
    
    @IBOutlet private weak var countryButton: UIButton!

    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var welcomeLabel: UILabel!

    let buyText = NSLocalizedString("Buy Data", comment: "Primary action button on Home")
    let refreshBalanceText = NSLocalizedString("Updating data balance...", comment: "Loading text while determining data balance.")

    private lazy var refreshControl = UIRefreshControl()

    private lazy var byteCountFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter
    }()

    private func showToppedUpMessage() {
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
    }

    private func hideMessage() {
        welcomeLabel.alpha = 0.0
        messageLabel.alpha = 0.0
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buyButton.setTitle(buyText, for: .normal)
        registerForPushNotificationsIfNeeded()
        balanceLabel.dataAmountString = nil

        scrollView.alwaysBounceVertical = true
        scrollView.bounces = true
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        refreshControl.attributedTitle = NSMutableAttributedString(string: refreshBalanceText)
        scrollView.addSubview(refreshControl)
        refreshBalance()
        
        NotificationCenter.default.addObserver(self, selector: #selector(countryChanged(_:)), name: CurrentCountryChanged, object: nil)
        updateButtonFor(country: LocationController.shared.currentCountry)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchProducts()
    }
    
    @objc func countryChanged(_ notification: NSNotification) {
        guard let controller = notification.object as? LocationController else {
            fatalError("Something other than the location controller is posting this notification!")
        }
        updateButtonFor(country: controller.currentCountry)
    }
    
    private func updateButtonFor(country: Country?) {
        countryButton.setTitle(country?.nameOrPlaceholder, for: .normal)
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

    internal func fetchProducts() {
        getProducts()
        .done { [weak self] products in
            products.forEach { debugPrint($0) }
            guard let self = self else {
                return
            }
            self.availableProducts = products
        }
        .catch { error in
            ApplicationErrors.log(error)
        }
    }

    override func paymentSuccessful(_ product: Product?) {
        refreshBalance()
        showToppedUpMessage()
        AppEvents.logEvent(.purchased)
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
        hideMessage()
        refreshBalance()
    }

    @IBAction private func buyDataTapped(_ sender: Any) {
        OstelcoAnalytics.logEvent(.BuyDataClicked)
        showProductListActionSheet(products: self.availableProducts)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setupApplePay", let toVC = segue.destination as? SetupApplePayViewController {
            toVC.delegate = self
        }
    }

    private func updateBalance(from bundles: [PrimeGQL.BundlesQuery.Data.Context.Bundle]) {
        guard let bundle = bundles.first else {
            return
        }
        
        let formattedBalance = self.byteCountFormatter.string(fromByteCount: bundle.balance)
        self.balanceLabel.dataAmountString = formattedBalance
    }

    private func showSetupApplePay() -> Bool {
        var showSetup = false
        let applePayError: ApplePayError? = canMakePayments()
        switch applePayError {
        case .unsupportedDevice?:
            debugPrint("Apple Pay is not supported on this device")
            showSetup = true
        case .noSupportedCards?:
            debugPrint("No supported cards setup in Apple Pay")
            showSetup = true
        case .otherRestrictions?:
            debugPrint("Some restriction with Apple Pay")
            showSetup = true
        default:
            debugPrint("Apple Pay is already setup")
            showSetup = false
        }
        if showSetup {
            performSegue(withIdentifier: "setupApplePay", sender: self)
        }
        return showSetup
    }

    private func showProductListActionSheet(products: [Product]) {
        let alertCtrl = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for product in products {
            let buyAction = UIAlertAction(title: product.label, style: .default) {_ in
                #if STRIPE_PAYMENT
                    self.startStripePay(product: product)
                #else
                // Before we start payment, check if Apple pay is setup correctly.
                if !self.showSetupApplePay() {
                    self.startApplePay(product: product)
                }
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

// MARK: - SetupApplePayViewControllerDelegate

extension HomeViewController: SetupApplePayViewControllerDelegate {
    func didFinish(sender: SetupApplePayViewController) {
        dismiss(animated: true)
    }

    func didCancel(sender: SetupApplePayViewController) {
        dismiss(animated: true)
    }
}
