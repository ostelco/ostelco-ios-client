//
//  BecomeAMemberViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/15/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import PassKit
import Stripe
import Siesta

class BecomeAMemberViewController: ApplePayViewController {

    @IBOutlet private weak var buttonContainer: UIView!

    var paymentButton: PKPaymentButton? = nil
    var plan: Product? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPaymentButton()
        let spinnerView: UIView = showSpinner(onView: view)
        getProducts { products, error in
            self.removeSpinner(spinnerView)
            self.plan = self.getFirstPlan(products)
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
        let applePayError:ApplePayError? = canMakePayments()
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
        // Properties to Setup Apple Pay.
        var action = #selector(BecomeAMemberViewController.setUpButtonTapped)
        var paymentButtonType: PKPaymentButtonType =  .setUp
        let paymentButton: PKPaymentButton
        if showSetupButton == false {
            action = #selector(BecomeAMemberViewController.buyButtonTapped)
            paymentButtonType =  .checkout
        }
        paymentButton = PKPaymentButton(paymentButtonType: paymentButtonType, paymentButtonStyle: .whiteOutline)
        paymentButton.addTarget(self, action: action, for: .touchUpInside)
        paymentButton.translatesAutoresizingMaskIntoConstraints = false
        buttonContainer.addSubview(paymentButton)
        // Layout the Payment button.
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
            debugPrint("No subscription plan found.")
            self.showAlert(title: "Subscription Error", msg: "Did not find a valid subscription plan.")
        }
    }

    @objc func setUpButtonTapped() {
        PKPassLibrary().openPaymentSetup()
    }

    @IBAction private func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    override func paymentSuccessful(_ product: Product?) {
        cancelButtonTapped(self)
    }
}
