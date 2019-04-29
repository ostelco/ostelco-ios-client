//
//  HomeViewController2.swift
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

class HomeViewController2: ApplePayViewController {

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

        let spinnerView: UIView = showSpinner(onView: view)
        getProducts { products, error in
            self.removeSpinner(spinnerView)
            self.availableProducts = products
            if let error = error {
                debugPrint("error fetching products \(error)")
            } else if products.isEmpty {
                debugPrint("No products available")
            }
            self.availableProducts.forEach {debugPrint($0.name, $0.amount, $0.currency, $0.country, $0.sku)}
            // Check if the customer is a member already.
            self.hasSubscription = self.checkForSubscription(products)
            // TODO: Remove this after the subscription purchase is implemented
            self.hasSubscription = false
        }
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

    func getProducts(completionHandler: @escaping ([Product], Error?) -> Void) {
        APIManager.sharedInstance.products.load()
            .onSuccess { entity in
                DispatchQueue.main.async {
                    if let products: [ProductModel] = entity.typedContent(ifNone: nil) {
                        products.forEach {debugPrint($0.sku, $0.properties)}
                        let availableProducts: [Product] = products.map { Product(from: $0, countryCode: "SG") }
                        completionHandler(availableProducts, nil)
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
