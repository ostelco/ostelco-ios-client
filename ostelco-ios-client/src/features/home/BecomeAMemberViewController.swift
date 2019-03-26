//
//  BecomeAMemberViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/15/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import PassKit
import Stripe
import Siesta

class BecomeAMemberViewController: UIViewController {
    
    var paymentError: RequestError!
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var paymentButtonContainer: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let paymentButton = PKPaymentButton(paymentButtonType: .buy
            , paymentButtonStyle: .black)
        paymentButton.translatesAutoresizingMaskIntoConstraints = false
        paymentButton.addTarget(self, action: #selector(BecomeAMemberViewController.paymentButtonTapped), for: .touchUpInside)

        paymentButtonContainer.addArrangedSubview(paymentButton)
    }
    
    @objc func paymentButtonTapped() {
        let product = Product(name: "membership fee, 1 year", amount: 1.0, country: "SG", currency: "SGD", sku: "123")
        startApplePay(product: product, delegate: self)
    }
}

extension BecomeAMemberViewController: PKPaymentAuthorizationViewControllerDelegate {
    
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
