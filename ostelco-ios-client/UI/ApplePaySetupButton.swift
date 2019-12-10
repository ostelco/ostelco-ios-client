//
//  ApplePaySetupButton.swift
//  ostelco-ios-client
//
//  Created by mac on 10/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import SwiftUI
import PassKit

struct ApplePaySetupButton: UIViewRepresentable {
    typealias UIViewType = UIView
    
    let paymentButtonType: PKPaymentButtonType
    
    func makeUIView(context: UIViewRepresentableContext<ApplePaySetupButton>) -> UIView {
        let buttonContainer = UIView()
        
        let paymentButton = PKPaymentButton(paymentButtonType: paymentButtonType, paymentButtonStyle: .black)
        paymentButton.translatesAutoresizingMaskIntoConstraints = false
        
        buttonContainer.addSubview(paymentButton)
        
        paymentButton.widthAnchor.constraint(equalTo: buttonContainer.widthAnchor).isActive = true
        paymentButton.heightAnchor.constraint(equalTo: buttonContainer.heightAnchor).isActive = true
        paymentButton.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor).isActive = true
        paymentButton.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor).isActive = true
        
        paymentButton.cornerRadius = 6.0
        
        return buttonContainer
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<ApplePaySetupButton>) {
        
    }
}

struct ApplePaySetupButton_Previews: PreviewProvider {
    static var previews: some View {
        ApplePaySetupButton(paymentButtonType: .setUp)
    }
}
