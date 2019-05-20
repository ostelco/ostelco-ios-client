//
//  ApplePayViewController.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 26/04/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import PassKit
import PromiseKit
import Stripe
import ostelco_core

// This is the base class for both HomeViewController and BecomeAMemberViewController
// 1) Adds properties defined by the ApplePayDelegate protocol
// 2) Adds @objc methods for PKPaymentAuthorizationViewControllerDelegate
// This class coudn't be avoided due to the issue described in the following link.
// TL;DR: @objc functions may not currently be in protocol extensions.
// You could create a base class instead, though that's not an ideal solution.
// https://stackoverflow.com/questions/39487168/non-objc-method-does-not-satisfy-optional-requirement-of-objc-protocol
class ApplePayViewController: UIViewController, ApplePayDelegate {

    // MARK: - Properties for ApplePayDelegate.

    var shownApplePay = false
    var authorizedApplePay = false
    var purchasingProduct: Product?
    var applePayError: ApplePayError?

    // MARK: - Properties for Stripe Payment.

    #if STRIPE_PAYMENT
        lazy var paymentContext: STPPaymentContext = {
            let customerContext = STPCustomerContext(keyProvider: self)
            let paymentContext = STPPaymentContext(customerContext: customerContext)
            paymentContext.delegate = self
            paymentContext.hostViewController = self
            return paymentContext
        }()
    #endif

    func paymentError(_ error: Error) {
        if let applePayError = error as? ApplePayError {
            switch applePayError {
            case .unsupportedDevice, .noSupportedCards, .otherRestrictions:
                self.showAlert(title: "Payment Error", msg: error.localizedDescription)
            case .userCancelled:
                debugPrint(error.localizedDescription, "Payment was cancelled after showing Apple Pay screen")
            case .paymentDeclined:
                debugPrint(error.localizedDescription, "Payment was declined")
                showOhNo(type: .paymentFailedCardDeclined)
            case .primeAPIError(let requestError):
                debugPrint(requestError.localizedDescription, "Payment failed")
                showOhNo(type: .paymentFailedGeneric)
            }
        } else {
            showAlert(title: "Payment Error", msg: error.localizedDescription)
        }
    }

    func showOhNo(type: OhNoViewController.IssueType) {
        let ohNo = OhNoViewController.fromStoryboard(type: type)
        ohNo.primaryButtonAction = {
            ohNo.dismiss(animated: true, completion: { [weak self] in
                guard let product = self?.purchasingProduct else {
                    debugPrint("Cannot find the purchasing product, cancel retry")
                    return
                }
                #if STRIPE_PAYMENT
                    self?.startStripePay(product: product)
                #else
                    self?.startApplePay(product: product)
                #endif
            })
        }
        present(ohNo, animated: true)
    }

    func paymentSuccessful(_ product: Product?) {
        self.showAlert(title: "Yay!", msg: "Imaginary confetti, and lots of it! \(String(describing: product?.name))")
    }

    func getProducts() -> Promise<[Product]> {
        return APIManager.shared.primeAPI
            .loadProducts()
            .map { productModels in
                productModels.map { Product(from: $0, countryCode: "SG") }
            }
    }
}

extension ApplePayViewController: PKPaymentAuthorizationViewControllerDelegate {

    // MARK: - Default implementaion of PKPaymentAuthorizationViewControllerDelegate.

    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController,
                                            didAuthorizePayment payment: PKPayment,
                                            handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        handlePaymentAuthorized(controller, didAuthorizePayment: payment, handler: completion)
    }

    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        handlePaymentFinished(controller)
    }
}

#if STRIPE_PAYMENT
// This extension supports payment through Stripe Standard UI components.
// Mainly used for testing prime payment APIs with different types of cards avaiable in Stripe.
// https://stripe.com/docs/testing
extension ApplePayViewController: STPPaymentContextDelegate, STPCustomerEphemeralKeyProvider {

    // This shows various payment options avaiable through stripe.
    // You can add new cards using  the presented UI
    func showPaymentOptions() {
        let paymentOptionsViewController = STPPaymentOptionsViewController(paymentContext: paymentContext)
        let navigationController = UINavigationController(rootViewController: paymentOptionsViewController)
        present(navigationController, animated: true)
    }

    // Do actual payment using  Stripe.
    // Payment is done using the default card you have selected using the showPaymentOptions API
    // If no card is present, this will show the payment options UI
    func startStripePay(product: Product) {
        purchasingProduct = product
        paymentContext.paymentAmount = Int(truncating: NSDecimalNumber(decimal: product.amount))
        paymentContext.paymentCurrency = product.currency
        paymentContext.requestPayment()
    }

    // Stripe is ready with a payment source, call Prime API to purchase the product
    func handleDidCreatePaymentResult(paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        guard let product = purchasingProduct else {
            debugPrint("No product to buy")
            return
        }
        // Call Prime API to buy the product.
        let payment = PaymentInfo(sourceID: paymentResult.source.stripeID)
        APIManager.shared.primeAPI.purchaseProduct(with: product.sku, payment: payment)
            .done {
                debugPrint("Successfully bought product \(product.sku)")
                completion(nil)
            }
            .catch { error in
                ApplicationErrors.log(error)
                debugPrint("Failed to buy product with sku %{public}@, got error: %{public}@", "123", "\(error)")
                completion(ApplePayError.primeAPIError(error))
            }
    }

    // MARK: - STPPaymentContextDelegate methods

    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        debugPrint(#function, error)
        paymentError(error)
    }

    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        debugPrint(#function)
    }

    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        debugPrint(#function)
        handleDidCreatePaymentResult(paymentResult: paymentResult, completion: completion)
    }

    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        switch status {
        case .error:
            debugPrint("Error while processing the payment: \(String(describing: error)))")
            if let error = error {
                paymentError(error)
            }
        case .success:
            debugPrint("Payment was successful")
            paymentSuccessful(purchasingProduct)
        case .userCancellation:
            debugPrint("User cancelled the payment")
        @unknown default:
            debugPrint("Payment finished with unknown status \(status)")
        }
    }

    // MARK: - STPCustomerEphemeralKeyProvider method

    // Called automatically by Stripe through the STPCustomerContext object
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        let request = StripeEphemeralKeyRequest(apiVersion: apiVersion)
        APIManager.shared.primeAPI.stripeEphemeralKey(with: request)
            .done { key in
                completion(key, nil)
            }
            .catch { error in
                ApplicationErrors.log(error)
                completion(nil, error)
            }
    }
}
#endif
