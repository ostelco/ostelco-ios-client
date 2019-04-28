//
//  UIViewController+StartApplePay.swift
//  ostelco-ios-client
//
//  Created by mac on 3/15/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Stripe
import Siesta

enum ApplePayError: Error {
    // Apple pay support related Errors
    case unsupportedDevice
    case noSupportedCards
    case otherRestrictions
    // Other errors during payment
    case userCancelled
    case primeAPIError(RequestError)
}

extension ApplePayError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unsupportedDevice:
            return "Your device does not support apple pay"
        case .noSupportedCards:
            return "You need to setup a card in your wallet, we support the following cards: American Express, Visa, Mastercard, Discover"
        case .otherRestrictions:
            return "Your device has some restrictions preventing payment (such as parental controls)"
        // Other errors during payment
        case .userCancelled:
            return "User has cancelled the payment"
        case .primeAPIError:
            return "Prime API Error"
        }
    }
}

protocol ApplePayDelegate: UIViewController, PKPaymentAuthorizationViewControllerDelegate {
    var shownApplePay: Bool { get set }
    var authorizedApplePay: Bool { get set }
    var purchasingProduct: Product? { get set }
    var applePayError: ApplePayError? { get set }

    func paymentError(_ error: ApplePayError)
    func paymentSuccessful(_ product: Product)
}

extension UIViewController {
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

    func startApplePay(product: Product, delegate: ApplePayDelegate) {
        delegate.shownApplePay = false
        delegate.authorizedApplePay = false
        delegate.purchasingProduct = product
        let merchantIdentifier = Environment().configuration(.AppleMerchantId)
        // TODO: Consult with Payment Service Provider (Stripe in our case) to determine which country code value to use
        // https://developer.apple.com/documentation/passkit/pkpaymentrequest/1619246-countrycode
        let paymentRequest = Stripe.paymentRequest(withMerchantIdentifier: merchantIdentifier, country: product.country, currency: product.currency)
        if let paymentError = canMakePayments() {
            delegate.paymentError(paymentError)
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
            paymentAuthorizationViewController!.delegate = delegate

            // Present payment authorization view controller
            delegate.shownApplePay = true
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
