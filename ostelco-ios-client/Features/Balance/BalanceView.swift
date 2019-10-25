//
//  HomeView.swift
//  ostelco-ios-client
//
//  Created by mac on 10/15/19.
//  Copyright © 2019 mac. All rights reserved.
//

import SwiftUI
import OstelcoStyles
import PassKit
import Stripe
import ostelco_core
import PromiseKit
import UIKit

// TODO: Only loading products once, not on view did appear as original VC did (does this matter?)
struct BalanceView: View {
    
    @EnvironmentObject var store: BalanceStore
    @EnvironmentObject var global: GlobalStore
    @State private var showProductsSheet = false
    @State private var presentApplePaySetup = false
    @Binding private var currentTab: Tabs
    
    init(currentTab: Binding<Tabs>) {
        self._currentTab = currentTab
    }
    
    private var buttons: [ActionSheet.Button] {
        var buttons: [ActionSheet.Button] = []

        // TODO: Use remote config instead
        #if STRIPE_PAYMENT
        buttons.append(
            .default(Text("Setup Cards"), action: {})
        )
        #endif
        store.products.forEach { product in
            buttons.append(
                .default(Text(product.label), action: {
                    #if STRIPE_PAYMENT
                    self.store.controller.startStripePay(product: product)
                    #else
                    // Before we start payment, check if Apple pay is setup correctly.
                    if !self.showApplePaySetup() {
                        self.store.controller.startApplePay(product: product)
                    }
                    #endif

                })
            )
        }
        buttons.append(
            .cancel(Text("Cancel"))
        )

        return buttons
    }
    
    private func showApplePaySetup() -> Bool {
        var showSetup = false
        let applePayError: ApplePayError? = self.store.controller.canMakePayments()
        switch applePayError {
        case .unsupportedDevice?:
            debugPrint("Apple Pay is not supported on this device")
            showSetup = true
        case .noSupportedCards?:
            debugPrint("No supported cards setup in Apple Pay")
            showSetup = true
        case .otherRestrictions?:
            debugPrint("Some restriction with Apple Pay")
            showSetup = true
        default:
            debugPrint("Apple Pay is already setup")
            showSetup = false
        }
        if showSetup {
            presentApplePaySetup.toggle()
        }
        return showSetup
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack(alignment: .firstTextBaseline) {
                    BalanceLabel(label: store.balance ?? "")
                }
                
                Text("remaining")
                    .font(.system(size: 21))
                    .foregroundColor(OstelcoColor.primaryButtonBackground.toColor)
                Button(action: {
                    OstelcoAnalytics.logEvent(.BuyDataClicked)
                    self.showProductsSheet.toggle()
                }) {
                    Text("Buy more Data")
                        .font(.system(size: 21, weight: .semibold))
                        .foregroundColor(OstelcoColor.background.toColor)
                    }
                .frame(width: 250, height: 56)
                .background(OstelcoColor.primaryButtonBackground.toColor)
                .cornerRadius(27.5)
            }
            renderOverlay()
            
        }.actionSheet(isPresented: $showProductsSheet) {
            ActionSheet(
                title: Text("Select a package"),
                buttons: buttons
            )
        }.sheet(isPresented: $presentApplePaySetup) {
            ApplePaySetupView()
        }.onAppear {
            if !self.store.hasAtLeastOneInstalledSimProfile {
                self.store.loadSimProfiles()
            }
            
            self.store.loadProducts()
        }
    }
    
    func renderOverlay() -> AnyView {
        if let country = global.country, global.showCountryNotSupportedMessage() {
                return AnyView(
                    MessageContainer(
                        messageType: .countryNotSupported(country: country)
                    )
                )
        } else if store.hasAtLeastOneInstalledSimProfile {
            if let country = global.showCountryChangedMessage() {
                return AnyView(
                    MessageContainer(messageType: .welcomeToCountry(action: { self.currentTab = .coverage }, country: country))
                )
            } else {
                return AnyView(EmptyView())
            }
        } else {
            return AnyView(
                MessageContainer(messageType: .welcomeNewUser(action: { self.currentTab = .coverage }))
            )
        }
    }
}

/*
struct HomeView_Previews: PreviewProvider {
    
    static var previews: some View {
        BalanceView()
    }
}*/
