//
//  BecomeAMemberViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/15/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import PassKit
import PromiseKit
import Stripe
import Siesta

class BecomeAMemberViewController: ApplePayViewController {

    @IBOutlet private weak var buttonContainer: UIView!

    var paymentButton: PKPaymentButton?
    var plan: Product?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPaymentButton()
        let spinnerView: UIView = showSpinner(onView: view)
        getProducts()
            .ensure { [weak self] in
                self?.removeSpinner(spinnerView)
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
            showSetupButton = true
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
            startApplePay(product: plan)
        } else {
            let error = ApplicationErrors.General.noValidPlansFound
            ApplicationErrors.log(error)
            self.showAlert(title: "Subscription Error", msg: error.localizedDescription)
        }
    }

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
