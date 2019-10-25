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
import FirebaseAnalytics

// TODO: Missing pull to refresh balance
// TODO: Only loading products once, not on view did appear as original VC did (does this matter?)
// TODO: Original VC registered for PN for some reason, not sure why
struct BalanceView: View {
    
    @EnvironmentObject var store: BalanceStore
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
                    OstelcoAnalytics.logEvent(.buyDataFlowStarted)
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
        }
    }
    
    func renderOverlay() -> AnyView {
        if store.hasAtLeastOneInstalledSimProfile {
            return AnyView(EmptyView())
        } else {
            return AnyView(
                Group {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                        }
                    }.background(OstelcoColor.fog.toColor)
                    ZStack {
                        VStack {
                            Spacer()
                            OstelcoContainer {
                                VStack(spacing: 20) {
                                    OstelcoTitle(label: "Welcome to OYA!")
                                    Text("Where would you like to start using your first 1GB of OYA data?")
                                        .font(.system(size: 21))
                                        .foregroundColor(OstelcoColor.inputLabel.toColor)
                                        .multilineTextAlignment(.center )
                                    Button(action: {
                                        self.currentTab = .coverage
                                    }) {
                                        ZStack {
                                            HStack {
                                                Image(systemName: "globe")
                                                    .font(.system(size: 30, weight: .light))
                                                    .foregroundColor(OstelcoColor.primaryButtonLabel.toColor)
                                                Spacer()
                                            }.padding(.leading, 10)
                                            Text("See Available Countries")
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundColor(OstelcoColor.primaryButtonLabel.toColor)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 50)
                                    .background(OstelcoColor.primaryButtonBackground.toColor)
                                    .cornerRadius(27.5)
                                }.padding(25)
                            }
                        }
                        
                        // Lazy way to hide the bottom rounded corners from the above container, a better solution would be to configure the corners in the container itself.
                        VStack {
                            Spacer()
                            Rectangle()
                                .fill(OstelcoColor.foreground.toColor)
                                .frame(maxWidth: .infinity, maxHeight: 25)
                        }
                    }
                }
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
