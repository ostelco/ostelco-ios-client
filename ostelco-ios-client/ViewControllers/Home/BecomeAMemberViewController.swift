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

    @IBAction private func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Make sure device supports apple pay and that there are no other restrictions preventing payment (like parental control)
        if PKPaymentAuthorizationViewController.canMakePayments() {
            
            let paymentButton: PKPaymentButton
            
            // 2. Check if user has a stripe supported card in its wallet
            if Stripe.deviceSupportsApplePay() {
                paymentButton = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
                paymentButton.addTarget(self, action: #selector(BecomeAMemberViewController.buyButtonTapped), for: .touchUpInside)
            } else {
                paymentButton = PKPaymentButton(paymentButtonType: .setUp, paymentButtonStyle: .black)
                paymentButton.addTarget(self, action: #selector(BecomeAMemberViewController.setUpButtonTapped), for: .touchUpInside)
            }
            paymentButton.translatesAutoresizingMaskIntoConstraints = false
            buttonContainer.addSubview(paymentButton)
            
            paymentButton.widthAnchor.constraint(equalTo: buttonContainer.widthAnchor).isActive = true
            paymentButton.heightAnchor.constraint(equalTo: buttonContainer.heightAnchor).isActive = true
            paymentButton.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor).isActive = true
            paymentButton.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor).isActive = true
            if #available(iOS 12.0, *) {
                paymentButton.cornerRadius = 8.0
            }
        }
        
    }
    
    @objc func buyButtonTapped() {
        let product = Product(
            name: "membership fee, 1 year",
            label: "membership fee, 1 year for $1",
            amount: 100.0,
            country: "SG",
            currency: "SGD",
            sku: "123"
        )
        startApplePay(product: product, delegate: self)
    }
    
    @objc func setUpButtonTapped() {
        PKPassLibrary().openPaymentSetup()
    }
}
