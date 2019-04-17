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

class HomeViewController2: UIViewController {

    var paymentError: RequestError!

    @IBOutlet private weak var balanceLabel: UILabel!
    @IBOutlet private weak var scrollView: UIScrollView!

    private lazy var refreshControl = UIRefreshControl()
    var fakeHasSubscription = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.typedDelegate.registerNotifications(authorise: true)

        scrollView.alwaysBounceVertical = true
        scrollView.bounces = true
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.scrollView.addSubview(refreshControl)
    }

    @objc func didPullToRefresh() {
        let delayInSeconds = 4.0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            self.refreshControl.endRefreshing()
        }
    }

    @IBAction private func buyDataTapped(_ sender: Any) {
        if fakeHasSubscription {
            let product = Product(name: "Buy 1GB for $5", amount: 5.0, country: "SG", currency: "SGD", sku: "1234")
            showProductListActionSheet(products: [product], delegate: self)
        } else {
            fakeHasSubscription = true
            performSegue(withIdentifier: "becomeMember", sender: self)
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
            if self.paymentError == nil {
                self.showAlert(title: "Yay!", msg: "Imaginary confetti, and lots of it!")
            } else {
                self.showAPIError(error: self.paymentError)
            }
        })
    }
}
