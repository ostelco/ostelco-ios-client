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

    var paymentError: RequestError!

    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!

    var refreshControl: UIRefreshControl!
    var hasSubscription = false
    var availableProducts: [Product] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.registerNotifications(authorise: true)

        scrollView.alwaysBounceVertical = true
        scrollView.bounces  = true
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.scrollView.addSubview(refreshControl)

        let spinnerView: UIView = showSpinner(onView: view)
        getProducts() { products, error in
            self.removeSpinner(spinnerView)
            self.availableProducts = products
            if let error = error {
                print("error fetching products \(error)")
            } else if products.count == 0 {
                print("No products available")
            }
            // TODO: check the if the customer is a member already.
            self.hasSubscription = false
        }
    }

    @objc func didPullToRefresh() {
        let delayInSeconds = 4.0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            self.refreshControl?.endRefreshing()
        }
    }

    @IBAction func buyDataTapped(_ sender: Any) {
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
                        let availableProducts:[Product] = products.map {
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
            if (self.paymentError == nil) {
                self.showAlert(title: "Yay!", msg: "Imaginary confetti, and lots of it!")
            } else {
                self.showAPIError(error: self.paymentError)
            }
        })
    }
}
