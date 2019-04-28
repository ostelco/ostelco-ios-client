//
//  ApplePayViewController.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 26/04/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import Stripe
import Siesta

// Default implementaion for the PKPaymentAuthorizationViewControllerDelegate methods.
class ApplePayViewController: UIViewController, ApplePayDelegate {

    // Properties for ApplePayDelegate protocol
    var shownApplePay = false
    var authorizedApplePay = false
    var purchasingProduct: Product?
    var applePayError: ApplePayError?

    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController,
                                            didAuthorizePayment payment: PKPayment,
                                            handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        authorizedApplePay = true
        let product = purchasingProduct!
        // Create Stripe Source.
        STPAPIClient.shared().createSource(with: payment) { (source: STPSource?, error: Error?) in
            guard let source = source, error == nil else {
                debugPrint(error!)
                completion(PKPaymentAuthorizationResult(status: .failure, errors: [error!]))
                self.showAlert(title: "Failed to create stripe source", msg: "\(error!.localizedDescription)")
                return
            }
            // Call Prime API to buy the product.
            APIManager.sharedInstance.products.child(product.sku).child("purchase").withParam("sourceId", source.stripeID).request(.post)
                .onProgress({ progress in
                    debugPrint("Progress %{public}@", "\(progress)")
                })
                .onSuccess({ result in
                    debugPrint("Successfully bought a product %{public}@", "\(result)")
                    completion(PKPaymentAuthorizationResult(status: .success, errors: []))
                })
                .onFailure({ error in
                    debugPrint("Failed to buy product with sku %{public}@, got error: %{public}@", "123", "\(error)")
                    completion(PKPaymentAuthorizationResult(status: .failure, errors: [error]))
                    self.applePayError = ApplePayError.primeAPIError(error)
                    // Wait for finish method before we call paymentError()
                })
        }
    }

    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        // Dismiss payment authorization view controller
        dismiss(animated: true, completion: {
            if let applePayError = self.applePayError {
                self.paymentError(applePayError)
            } else if self.authorizedApplePay {
                self.paymentSuccessful(self.purchasingProduct!)
            } else {
                self.paymentError(ApplePayError.userCancelled)
            }
        })
    }

    func paymentError(_ error: ApplePayError) {
        switch error {
        case .unsupportedDevice, .noSupportedCards, .otherRestrictions:
            self.showAlert(title: "Payment Error", msg: error.localizedDescription)
        case .userCancelled:
            debugPrint(error.localizedDescription, "Payment was cancelled after showing Apple Pay screen")
        case .primeAPIError(let requestError):
            showAPIError(error: requestError)
        }
    }

    func paymentSuccessful(_ product: Product) {
        self.showAlert(title: "Yay!", msg: "Imaginary confetti, and lots of it! \(product.name)")
    }
}
