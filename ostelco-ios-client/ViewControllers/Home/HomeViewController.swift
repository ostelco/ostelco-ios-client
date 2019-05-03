//
//  HomeViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/25/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import Stripe
import Siesta
import ostelco_core
import OstelcoStyles

class HomeViewController: ApplePayViewController {

    var paymentError: RequestError?
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

    private func showWelcomeMessage() {
        welcomeLabel.isHidden = false
        messageLabel.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.welcomeLabel.isHidden = true
            self?.messageLabel.isHidden = true
        }
    }

    private func checkForSubscription(_ products: [Product]) -> Bool {
        // See if the list contains offers.
        let hasOffers = products.contains { $0.type == "offer" }
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
                // TODO: Remove this after the subscription purchase is implemented
                self.hasSubscription = false
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
        getBundles { bundles, _ in
            if let bundle = bundles.first {
                let formatter: ByteCountFormatter = ByteCountFormatter()
                formatter.countStyle = .binary
                let formattedBalance = formatter.string(fromByteCount: bundle.balance)
                self.balanceLabel.text = formattedBalance
            }
            print(bundles)
            self.refreshControl.endRefreshing()
        }
    }

    @IBAction private func buyDataTapped(_ sender: Any) {
        if hasSubscription {
            // TODO: Should we show the plans here ?
            showProductListActionSheet(products: self.availableProducts)
        } else {
            // TODO: Remove this after the subscription purchase is implemented
            hasSubscription = true
            performSegue(withIdentifier: "becomeMember", sender: self)
        }
    }

    // Shows the list of products in a sheet
    private func showProductListActionSheet(products: [Product]) {
        let alertCtrl = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for product in products {
            let buyAction = UIAlertAction(title: product.label, style: .default) {_ in
                self.startApplePay(product: product)
            }
            alertCtrl.addAction(buyAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertCtrl.addAction(cancelAction)
        present(alertCtrl, animated: true, completion: nil)
    }

    func getBundles(completionHandler: @escaping ([BundleModel], Error?) -> Void) {
        APIManager.sharedInstance.bundles.load()
            .onSuccess { entity in
                DispatchQueue.main.async {
                    if let bundles: [BundleModel] = entity.typedContent(ifNone: nil) {
                        completionHandler(bundles, nil)
                    } else {
                        completionHandler([], nil)
                    }
                }
            }
            .onFailure { error in
                DispatchQueue.main.async {
                    completionHandler([], error)
                }
        }
    }
}
