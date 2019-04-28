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

// This class coudn't be avoided due to the issue described in the following link.
// TL;DR: @objc functions may not currently be in protocol extensions.
// You could create a base class instead, though that's not an ideal solution.
// https://stackoverflow.com/questions/39487168/non-objc-method-does-not-satisfy-optional-requirement-of-objc-protocol
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

    func startApplePay(product: Product) {
        shownApplePay = false
        authorizedApplePay = false
        purchasingProduct = product
        let merchantIdentifier = Environment().configuration(.AppleMerchantId)
        // TODO: Consult with Payment Service Provider (Stripe in our case) to determine which country code value to use
        // https://developer.apple.com/documentation/passkit/pkpaymentrequest/1619246-countrycode
        let paymentRequest = Stripe.paymentRequest(withMerchantIdentifier: merchantIdentifier, country: product.country, currency: product.currency)
        if let applePayError = canMakePayments() {
            paymentError(applePayError)
            return
        }
        // Convert to acutal amount (prime uses currency’s smallest unit)
        let applePayAmount = convertStripeToNormalCurrency(amount: product.amount, currency: product.currency)
        // Configure the line items on the payment request
        paymentRequest.paymentSummaryItems = [
            PKPaymentSummaryItem(label: product.name, amount: applePayAmount),
            PKPaymentSummaryItem(label: "Red Otter", amount: applePayAmount),
        ]

        // Continued in next step
        if Stripe.canSubmitPaymentRequest(paymentRequest) {
            // Setup payment authorization view controller
            let paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
            paymentAuthorizationViewController!.delegate = self

            // Present payment authorization view controller
            shownApplePay = true
            present(paymentAuthorizationViewController!, animated: true)
        } else {
            // There is a problem with your Apple Pay configuration
            debugPrint("There is a problem with your Apple Pay configuration, we should have caught this before...")
            // TODO: Report error to bug reporting system
            #if DEBUG
            #if targetEnvironment(simulator)
            self.showAlert(title: "There is a problem with your Apple Pay configuration", msg: "Apple pay in test mode on simulator is supposed to work. Don't know why it failed.")
            #else
            self.showAlert(title: "There is a problem with your Apple Pay configuration", msg: "Apple pay in test mode on real devices has not been tested yet.")
            #endif
            #else
            #if targetEnvironment(simulator)
            self.showAlert(title: "There is a problem with your Apple Pay configuration", msg: "Apple pay in production mode on simulator does not work.")
            #else
            self.showAlert(title: "There is a problem with your Apple Pay configuration", msg: "Apple pay in production mode failed for unknown reason.")
            #endif
            #endif
        }
    }

    func showProductListActionSheet(products: [Product]) {
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

    func canMakePayments() -> ApplePayError? {
        let deviceAllowed = PKPaymentAuthorizationViewController.canMakePayments()
        let cardNetworks: [PKPaymentNetwork] = [.amex, .visa, .masterCard, .discover]
        let cardsAllowed = PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: cardNetworks)
        let stripeAllowed = Stripe.deviceSupportsApplePay()
        switch (deviceAllowed, cardsAllowed, stripeAllowed) {
        case (true, true, false):
            return ApplePayError.otherRestrictions
        case (true, false, _):
            return ApplePayError.noSupportedCards
        case (false, _, _):
            return ApplePayError.unsupportedDevice
        case (true, true, true):
            return nil
        }
    }

    // Stripe (& Prime) expects amounts to be provided in currency's smallest unit.
    // https://stripe.com/docs/currencies#zero-decimal
    // https://github.com/stripe/stripe-ios/blob/v15.0.1/Stripe/NSDecimalNumber%2BStripe_Currency.m
    func convertStripeToNormalCurrency(amount: Decimal, currency: String) -> NSDecimalNumber {
        let zeroDecimalCountries = [
            "bif", "clp", "djf", "gnf", "jpy",
            "kmf", "krw", "mga", "pyg", "rwf",
            "vnd", "vuv", "xaf", "xof", "xpf"
        ]
        let amountInCurrency = NSDecimalNumber(decimal: amount)
        if zeroDecimalCountries.contains(currency.lowercased()) {
            return amountInCurrency
        } else {
            return amountInCurrency.multiplying(byPowerOf10: -2)
        }
    }
}
