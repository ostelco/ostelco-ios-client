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

    @IBOutlet weak var buttonContainer: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()


        // 1. Make sure device supports apple pay and that there are no other restrictions preventing payment (like parental control)
        if PKPaymentAuthorizationViewController.canMakePayments() {
            
            let paymentButton: PKPaymentButton

            // 2. Check if user has a stripe supported card in its wallet
            if Stripe.deviceSupportsApplePay() {
                paymentButton = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
                paymentButton.addTarget(self, action: #selector(BecomeAMemberViewController.buyButtonTapped), for: .touchUpInside)
            } else {
                paymentButton = PKPaymentButton(paymentButtonType: .setUp, paymentButtonStyle: .black)
                paymentButton.addTarget(self, action: #selector(BecomeAMemberViewController.setUpButtonTapped), for: .touchUpInside)
            }

            paymentButton.translatesAutoresizingMaskIntoConstraints = false
            buttonContainer.addSubview(paymentButton)

            paymentButton.widthAnchor.constraint(equalTo: buttonContainer.widthAnchor).isActive = true
            paymentButton.heightAnchor.constraint(equalTo: buttonContainer.heightAnchor).isActive = true
            paymentButton.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor).isActive = true
            paymentButton.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor).isActive = true
            if #available(iOS 12.0, *) {
                paymentButton.cornerRadius = 8.0
            }
        }
        
    }

    @objc func buyButtonTapped() {
        let product = Product(name: "membership fee, 1 year", amount: 1.0, country: "SG", currency: "SGD", sku: "123")
        startApplePay(product: product, delegate: self)
    }

    @objc func setUpButtonTapped() {
        PKPassLibrary().openPaymentSetup()
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
