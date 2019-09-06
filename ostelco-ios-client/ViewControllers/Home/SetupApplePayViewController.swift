//
//  SetupApplePayViewController.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 05/09/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import OstelcoStyles
import PassKit
import PromiseKit
import Stripe
import UIKit

class SetupApplePayViewController: ApplePayViewController {

    @IBOutlet private var buttonContainer: UIView!
    @IBOutlet private var explanatoryCopyLabel: BodyTextLabel!

    var paymentButton: PKPaymentButton?
    var membership: Product?

    lazy var linkableCopy: LinkableText = {
        return LinkableText(
            fullText: NSLocalizedString("For now, we only accept payment through  Visa, Mastercard and American Express through Apple Pay.\n\nPlease click on the button below to set it up.\n\nRead about our current prices", comment: "Explanation for why a user need to setup Apple Pay"),
            linkedBits: [
                Link(
                    NSLocalizedString("Read about our current prices", comment: "Explanation for why a user need to setup Apple Pay: linkable part: current prices"),
                    url: ExternalLink.currentPricing.url
                ),
            ])!
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.explanatoryCopyLabel.tapDelegate = self
        self.explanatoryCopyLabel.setLinkableText(self.linkableCopy)

        setupPaymentButton()
    }

    func setupPaymentButton() {
        // Log information about the current Apple Pay setup.
        let applePayError: ApplePayError? = canMakePayments()
        switch applePayError {
        case .unsupportedDevice?:
            debugPrint("Apple Pay is not supported on this device")
        case .noSupportedCards?:
            debugPrint("No supported cards setup in Apple Pay")
        case .otherRestrictions?:
            debugPrint("Some restriction with Apple Pay")
        default:
            debugPrint("Apple Pay is already setup, we should never show this")
        }
        // Properties to Setup Apple Pay.
        let action = #selector(SetupApplePayViewController.setUpButtonTapped)
        let paymentButtonType = PKPaymentButtonType.setUp

        let paymentButton = PKPaymentButton(paymentButtonType: paymentButtonType, paymentButtonStyle: .black)
        paymentButton.addTarget(self, action: action, for: .touchUpInside)
        paymentButton.translatesAutoresizingMaskIntoConstraints = false
        buttonContainer.addSubview(paymentButton)
        // Layout the Apple Pay button.
        paymentButton.widthAnchor.constraint(equalTo: buttonContainer.widthAnchor).isActive = true
        paymentButton.heightAnchor.constraint(equalTo: buttonContainer.heightAnchor).isActive = true
        paymentButton.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor).isActive = true
        paymentButton.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor).isActive = true
        paymentButton.cornerRadius = 8.0
        self.paymentButton = paymentButton
    }

    @objc func setUpButtonTapped() {
        PKPassLibrary().openPaymentSetup()
        // Go back to home screen.
        dismiss(animated: true)
    }

    @IBAction private func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension SetupApplePayViewController: StoryboardLoadable {

    static var storyboard: Storyboard {
        return .home
    }

    static var isInitialViewController: Bool {
        return false
    }
}

// MARK: - LabelTapDelegate

extension SetupApplePayViewController: LabelTapDelegate {

    func tappedLink(_ link: Link) {
        UIApplication.shared.open(link.url)
    }
}
