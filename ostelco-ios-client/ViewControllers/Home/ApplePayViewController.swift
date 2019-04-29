//
//  ApplePayViewController.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 26/04/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import PassKit
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

    func paymentSuccessful(_ product: Product?) {
        self.showAlert(title: "Yay!", msg: "Imaginary confetti, and lots of it! \(String(describing: product?.name))")
    }

    func getProducts(completionHandler: @escaping ([Product], Error?) -> Void) {
        APIManager.sharedInstance.products.load()
            .onSuccess { entity in
                DispatchQueue.main.async {
                    if let products: [ProductModel] = entity.typedContent(ifNone: nil) {
                        products.forEach {debugPrint($0.sku, $0.properties)}
                        let availableProducts: [Product] = products.map { Product(from: $0, countryCode: "SG") }
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
