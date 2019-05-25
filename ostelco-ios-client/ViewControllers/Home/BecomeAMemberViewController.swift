//
//  BecomeAMemberViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/15/19.
//  Copyright © 2019 mac. All rights reserved.
//

import OstelcoStyles
import PassKit
import PromiseKit
import Stripe
import UIKit

class BecomeAMemberViewController: ApplePayViewController {

    @IBOutlet private var buttonContainer: UIView!
    @IBOutlet private var explanatoryCopyLabel: BodyTextLabel!

    var paymentButton: PKPaymentButton?
    var plan: Product?
    
    lazy var linkableCopy: LinkableText = {
        return LinkableText(fullText: """
To buy data you need to become an OYA member.

As an OYA member you keep your data forever.

$1 = 1 year of membership.

Read about our current prices
""",
                            linkedBits: [
                                "As an OYA member",
                                "Read about our current prices",
                            ])!
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.explanatoryCopyLabel.tapDelegate = self
        self.explanatoryCopyLabel.setLinkableText(self.linkableCopy)
        
        setupPaymentButton()
        paymentButton?.isEnabled = false
        getProducts()
            .ensure { [weak self] in
                self?.paymentButton?.isEnabled = true
            }
            .done { [weak self] products in
                guard let self = self else {
                    return
                }
                self.plan = self.getFirstPlan(products)
            }
            .catch { error in
                ApplicationErrors.log(error)
            }
    }

    private func getFirstPlan(_ products: [Product]) -> Product? {
        // See if the list contains offers.
        if let firstPlan = products.first(where: { $0.type == "plan" }) {
            return firstPlan
        }
        return nil
    }

    func setupPaymentButton() {
        var showSetupButton = false
        // Find out what kind of Apple Pay button we should show.
        let applePayError: ApplePayError? = canMakePayments()
        switch applePayError {
        case .unsupportedDevice?:
            debugPrint("Apple Pay is not supported on this device")
            return
        case .noSupportedCards?,
             .otherRestrictions?:
            #if STRIPE_PAYMENT
                // If we're doing stripe payments, it doesn't matter whether we have apple pay set up or not
                showSetupButton = false
            #else
                showSetupButton = true
            #endif
        default:
            showSetupButton = false
        }
        let action: Selector
        let paymentButtonType: PKPaymentButtonType
        if showSetupButton {
            // Properties to Setup Apple Pay.
            action = #selector(BecomeAMemberViewController.setUpButtonTapped)
            paymentButtonType = .setUp
        } else {
            // Properties to Checkout using Apple Pay.
            action = #selector(BecomeAMemberViewController.buyButtonTapped)
            paymentButtonType = .checkout
        }
        // Create the right type of Apple Pay button based on the checks above.
        let paymentButton = PKPaymentButton(paymentButtonType: paymentButtonType, paymentButtonStyle: .whiteOutline)
        paymentButton.addTarget(self, action: action, for: .touchUpInside)
        paymentButton.translatesAutoresizingMaskIntoConstraints = false
        buttonContainer.addSubview(paymentButton)
        // Layout the Apple Pay button.
        paymentButton.widthAnchor.constraint(equalTo: buttonContainer.widthAnchor).isActive = true
        paymentButton.heightAnchor.constraint(equalTo: buttonContainer.heightAnchor).isActive = true
        paymentButton.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor).isActive = true
        paymentButton.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor).isActive = true
        if #available(iOS 12.0, *) {
            paymentButton.cornerRadius = 8.0
        }
        self.paymentButton = paymentButton
    }

    @objc func buyButtonTapped() {
        if let plan = plan {
            #if STRIPE_PAYMENT
                showStripePaymentActionSheet(plan: plan)
            #else
                startApplePay(product: plan)
            #endif
        } else {
            let error = ApplicationErrors.General.noValidPlansFound
            ApplicationErrors.log(error)
            self.showAlert(title: "Subscription Error", msg: error.localizedDescription)
        }
    }

    #if STRIPE_PAYMENT
    private func showStripePaymentActionSheet(plan: Product) {
        let alertCtrl = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let buyAction = UIAlertAction(title: plan.label, style: .default) {_ in
            self.startStripePay(product: plan)
        }
        alertCtrl.addAction(buyAction)
        let addCardsAction = UIAlertAction(title: "Setup Cards", style: .default) {_ in
            self.showPaymentOptions()
        }
        alertCtrl.addAction(addCardsAction)
        alertCtrl.addAction(.cancelAction())
        self.presentActionSheet(alertCtrl)
    }
    #endif

    @objc func setUpButtonTapped() {
        PKPassLibrary().openPaymentSetup()
        // Go back to home screen.
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    override func paymentSuccessful(_ product: Product?) {
        HomeViewController.newSubscriber = true
        cancelButtonTapped(self)
    }
}

extension BecomeAMemberViewController: StoryboardLoadable {
    
    static var storyboard: Storyboard {
        return .home
    }
    
    static var isInitialViewController: Bool {
        return false
    }
}

// MARK: - LabelTapDelegate

extension BecomeAMemberViewController: LabelTapDelegate {
    
    func tappedAttributedLabel(_ label: UILabel, at characterIndex: Int) {
        guard let tappedLink = self.linkableCopy.linkedText(at: characterIndex) else {
            // No link was tapped
            return
        }
        
        guard
            let bits = self.linkableCopy.linkedBits,
            bits.count == 2,
            bits.contains(tappedLink) else {
                ApplicationErrors.assertAndLog("Unexpected link copy \(tappedLink)")
                return
        }
        
        // TODO: Update these to switch on localized strings
        switch tappedLink {
        case "As an OYA member":
            UIApplication.shared.open(ExternalLink.aboutMembership.url)
        case "Read about our current prices":
            UIApplication.shared.open(ExternalLink.currentPricing.url)
        default:
            fatalError("This should have been caught in the guard stement above!")
        }
    }
}
