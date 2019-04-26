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

class HomeViewController2: ApplePayViewController {

    var paymentError: RequestError?
    var availableProducts: [Product] = []

    @IBOutlet private weak var balanceLabel: UILabel!
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
            // TODO: check the if the customer is a member already.
            self.hasSubscription = false
        }
        refreshControl.beginRefreshing()
        didPullToRefresh()
    }

    // Make the string with all the styles required for the balance text
    // Input text e.g. "54.5 GB"
    class func getStylizeBalanceString(text: String) -> NSMutableAttributedString {
        let decimalSeparator: String = Locale.current.decimalSeparator!
        // TODO Fonts should be Telenor-Bold
        let bigFont = UIFont.boldSystemFont(ofSize: 84)
        let smallFont = UIFont.boldSystemFont(ofSize: 28)

        // Split text to 2 parts, number and units
        let textArray: [String] = text.components(separatedBy: " ")
        guard textArray.count >= 2 else {
            return NSMutableAttributedString(string: text)
        }

        // Split number string to integer and decimal parts.
        let numberArray: [String] = textArray[0].components(separatedBy: decimalSeparator)
        guard numberArray.count >= 1 else {
            return NSMutableAttributedString(string: text)
        }

        let integerPart = numberArray[0]
        // If there is a decimal part.
        let decimalPart: String? = (numberArray.count >= 2) ? "\(decimalSeparator)\(numberArray[1])": nil
        let unit = " \(textArray[1])"

        // Add integer part with the big font.
        let attrString = NSMutableAttributedString(string: integerPart, attributes: [.font: bigFont])
        if let decimalPart = decimalPart {
            // Add decimal part including the decimal character
            // This portion of text is aligned to top with a smaller font
            let offset = bigFont.capHeight - smallFont.capHeight
            let attributes: [NSAttributedString.Key: Any] = [
                .font: smallFont,
                .baselineOffset: offset
            ]
            attrString.append(NSMutableAttributedString(string: decimalPart, attributes: attributes))
        }
        // Add the modifier part with bigger font.
        attrString.append(NSMutableAttributedString(string: unit, attributes: [.font: bigFont]))
        return attrString
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
                let attributedText = HomeViewController2.getStylizeBalanceString(text: formattedBalance)
                self.balanceLabel.attributedText = attributedText
            }
            print(bundles)
            self.refreshControl.endRefreshing()
        }
    }
    
    @IBAction private func buyDataTapped(_ sender: Any) {
        if hasSubscription {
            showProductListActionSheet(products: self.availableProducts, delegate: self)
        } else {
            // TODO: Remove this after the logic for subscription check is implemented
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
