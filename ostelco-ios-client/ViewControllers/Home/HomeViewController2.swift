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

class HomeViewController2: UIViewController {
    
    var paymentError: RequestError?
    
    @IBOutlet private weak var balanceLabel: UILabel!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var buyButton: UIButton!

    let unlockText = "Unlock More Data"
    let buyText = "Buy Data"

    private lazy var refreshControl = UIRefreshControl()
    var hasSubscription = false {
        didSet {
            buyButton.setTitle(
                (hasSubscription == false) ? unlockText : buyText,
                for: .normal
            )
        }
    }
    var availableProducts: [Product] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.typedDelegate.registerNotifications(authorise: true)
        
        scrollView.alwaysBounceVertical = true
        scrollView.bounces = true
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.scrollView.addSubview(refreshControl)

        let spinnerView: UIView = showSpinner(onView: view)
        getProducts { products, error in
            self.removeSpinner(spinnerView)
            self.availableProducts = products
            if let error = error {
                print("error fetching products \(error)")
            } else if products.isEmpty {
                print("No products available")
            }
            // TODO: check the if the customer is a member already.
            self.hasSubscription = false
        }
        didPullToRefresh()
    }

    // Make the string with all the styles required for the balance text
    // Input text e.g. "54.5 GB"
    class func getStylizeBalanceString(text: String) -> NSMutableAttributedString {
        let decimalSeparator: String = Locale.current.decimalSeparator!
        let bigFont = UIFont.boldSystemFont(ofSize: 84)
        let smallFont = UIFont.boldSystemFont(ofSize: 36)

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
                        let availableProducts: [Product] = products.map {
                            Product(
                                name: "Buy \($0.presentation.label) for \($0.presentation.price)",
                                amount: Decimal($0.price.amount),
                                country: "SG",
                                currency: $0.price.currency,
                                sku: $0.sku)
                        }
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

extension HomeViewController2: PKPaymentAuthorizationViewControllerDelegate {
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        STPAPIClient.shared().createSource(with: payment) { (source: STPSource?, error: Error?) in
            guard let source = source, error == nil else {
                // Present error to user...
                self.showAlert(title: "Failed to create stripe source", msg: "\(error!.localizedDescription)")
                return
            }
            
            APIManager.sharedInstance.products.child("123").child("purchase").withParam("sourceId", source.stripeID).request(.post)
                .onProgress({ progress in
                    print("Progress %{public}@", "\(progress)")
                })
                .onSuccess({ result in
                    print("Successfully bought a product %{public}@", "\(result)")
                    // ostelcoAPI.purchases.invalidate()
                    // ostelcoAPI.bundles.invalidate()
                    // ostelcoAPI.bundles.load()
                    self.paymentError = nil
                    completion(.success)
                })
                .onFailure({ error in
                    // TODO: Report error to server
                    print("Failed to buy product with sku %{public}@, got error: %{public}@", "123", "\(error)")
                    self.paymentError = error
                    completion(.failure)
                })
                .onCompletion({ _ in
                    
                })
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        // Dismiss payment authorization view controller
        dismiss(animated: true, completion: {
            if let error = self.paymentError {
                self.showAPIError(error: error)
            } else {
                self.showAlert(title: "Yay!", msg: "Imaginary confetti, and lots of it!")
            }
        })
    }
}
