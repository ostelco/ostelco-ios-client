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
    
    let paymentButtonType: PKPaymentButtonType
    
    func makeUIView(context: Context) -> PKPaymentButton {
        let paymentButton = PKPaymentButton(paymentButtonType: paymentButtonType, paymentButtonStyle: .black)
        paymentButton.translatesAutoresizingMaskIntoConstraints = false
        paymentButton.cornerRadius = 8.0
        return paymentButton
    }
    
    func updateUIView(_ button: PKPaymentButton, context: Context) {
        
    }
}
struct ApplePaySetupButton_Previews: PreviewProvider {
    static var previews: some View {
        ApplePaySetupButton(paymentButtonType: .setUp)
    }
}
