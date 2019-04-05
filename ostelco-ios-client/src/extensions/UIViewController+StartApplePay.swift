//
//  UIViewController+StartApplePay.swift
//  ostelco-ios-client
//
//  Created by mac on 3/15/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Stripe
import Siesta

extension UIViewController {
    func startApplePay(product: Product, delegate: PKPaymentAuthorizationViewControllerDelegate) {
        let merchantIdentifier = Environment().configuration(.AppleMerchantId)
        let paymentRequest = Stripe.paymentRequest(withMerchantIdentifier: merchantIdentifier, country: product.country, currency: product.currency)

        if (!PKPaymentAuthorizationViewController.canMakePayments()) {
            self.showAlert(title: "Payment Error", msg: "Your device does not support apple pay")
            return
        }

        if (!Stripe.deviceSupportsApplePay()) {
            self.showAlert(title: "Payment Error", msg: "You need to setup a card in your wallet, we support the following cards: American Express, Visa, Mastercard, Discover")
            return
        }

        if (!PKPaymentAuthorizationViewController.canMakePayments()) {
            self.showAlert(title: "Payment Error", msg: "Wallet empty or does not contain any of the supported card types. Should give user option to open apple wallet to add a card.")
            return
        }

        // Configure the line items on the payment request
        paymentRequest.paymentSummaryItems = [
            PKPaymentSummaryItem(label: product.name, amount: product.amount as NSDecimalNumber),
        ]

        // Continued in next step
        if Stripe.canSubmitPaymentRequest(paymentRequest) {
            // Setup payment authorization view controller
            let paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
            paymentAuthorizationViewController!.delegate = delegate

            // Present payment authorization view controller
            present(paymentAuthorizationViewController!, animated: true)
        }
        else {
            // There is a problem with your Apple Pay configuration
            print("There is a problem with your Apple Pay configuration")
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
}

class PaymentError {
    var paymentError: RequestError!
}
