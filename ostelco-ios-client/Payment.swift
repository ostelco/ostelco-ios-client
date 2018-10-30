//
//  Payment.swift
//  ostelco-ios-client
//
//  Created by mac on 10/30/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation
import Stripe
import os

extension HomeViewController {
    // TODO: Possibly refactor this to a separate class
    
    func handleApplePayButtonTapped() {
        let merchantIdentifier = "merchant.sg.redotter.alpha"
        let paymentRequest = Stripe.paymentRequest(withMerchantIdentifier: merchantIdentifier, country: "SG", currency: product!.price.currency)
        
        // Configure the line items on the payment request
        paymentRequest.paymentSummaryItems = [
            PKPaymentSummaryItem(label: self.product!.presentation.label, amount: Decimal(Double(self.product!.price.amount) / 100.0) as NSDecimalNumber),
            // The final line should represent your company;
            // it'll be prepended with the word "Pay" (i.e. "Pay iHats, Inc $50")
            // PKPaymentSummaryItem(label: "iHats, Inc", amount: 50.00),
        ]
        
        // Continued in next step
        if Stripe.canSubmitPaymentRequest(paymentRequest) {
            // Setup payment authorization view controller
            let paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
            paymentAuthorizationViewController!.delegate = self
            
            // Present payment authorization view controller
            present(paymentAuthorizationViewController!, animated: true)
        }
        else {
            // There is a problem with your Apple Pay configuration
        }
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        STPAPIClient.shared().createSource(with: payment) { (source: STPSource?, error: Error?) in
            guard let source = source, error == nil else {
                // Present error to user...
                return
            }
            
            ostelcoAPI.products.child(self.product!.sku).child("purchase").withParam("sourceId", source.stripeID).request(.post)
                .onProgress({ progress in
                    os_log("Progress %{public}@", "\(progress)")
                })
                .onSuccess({ result in
                    os_log("Successfully bought a product %{public}@", "\(result)")
                    ostelcoAPI.purchases.invalidate()
                    ostelcoAPI.bundles.invalidate()
                    ostelcoAPI.bundles.load()
                    self.paymentSucceeded = true
                    completion(.success)
                })
                .onFailure({ error in
                    // TODO: Report error to server
                    // TODO: fix use of insecure unwrapping, can cause application to crash
                    os_log("Failed to buy product with sku %{public}@, got error: %{public}@", self.product!.sku, "\(error)")
                    self.paymentSucceeded = false
                    completion(.failure)
                })
                .onCompletion({ _ in
                    // UIViewController.removeSpinner(spinner: sv)
                })
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        // Dismiss payment authorization view controller
        dismiss(animated: true, completion: {
            if (self.paymentSucceeded) {
                // Show a receipt page...
                os_log("Show receipt page?")
            }
        })
    }
}
