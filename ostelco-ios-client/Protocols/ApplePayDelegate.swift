//
//  ApplePayDelegate.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 28/04/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import Siesta
import Stripe

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
