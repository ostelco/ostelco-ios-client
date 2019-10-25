//
//  ApplePaySetupView.swift
//  ostelco-ios-client
//
//  Created by mac on 10/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import SwiftUI
import OstelcoStyles
import PassKit

struct ApplePaySetupView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 25) {
            OstelcoTitle(label: "OYA uses Apple Pay")
            Text("For now, we only accept payment through Apple Pay.")
                .font(.system(size: 21))
                .foregroundColor(OstelcoColor.blackForText.toColor)
                .multilineTextAlignment(.center)
            Text("Please click on the button below to set it up.")
                .font(.system(size: 21))
                .foregroundColor(OstelcoColor.blackForText.toColor)
                .multilineTextAlignment(.center)
            Spacer()
            
            ApplePaySetupButton(paymentButtonType: .setUp)
                .frame(height: 44)
                .onTapGesture {
                    OstelcoAnalytics.logEvent(.setupApplePay)
                    PKPassLibrary().openPaymentSetup()
            }
        }.padding(20)
    }
}

struct ApplePaySetupView_Previews: PreviewProvider {
    static var previews: some View {
        ApplePaySetupView()
    }
}
