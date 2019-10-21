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

// TODO: Missing pull to refresh balance
// TODO: Only loading products once, not on view did appear as original VC did (does this matter?)
// TODO: Original VC registered for PN for some reason, not sure why
struct BalanceView: View {
    
    @EnvironmentObject var store: BalanceStore
    @State private var showProductsSheet = false
    @State private var presentApplePaySetup = false
    @State private var showSuccessText = false
    @Binding private var currentTab: Tabs
    
    init(currentTab: Binding<Tabs>) {
        self._currentTab = currentTab
    }
    
    private func handlePaymentSuccess(_ product: Product?) {
        self.showSuccessText.toggle()
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
    
    private func renderSuccessText() -> AnyView {
        if showSuccessText {
            return AnyView(
                Text("You have been topped up!")
            )
        }
        
        return AnyView(EmptyView())
    }
    
    private func showApplePaySetup() -> Bool {
        var showSetup = false
        let applePayError: ApplePayError? = ApplePayView.canMakePayment()
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
    
    private func handleError(error: Error) -> Void {
        debugPrint(error)
        // TODO: Present error to user using OhNo screen with switch cases, got to create OhNo screen using swiftUI
    }
    
    var body: some View {
        ZStack {
            VStack {
                
                renderSuccessText()
                
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
                    Text("Buy Data")
                        .font(.system(size: 21, weight: .semibold))
                        .foregroundColor(OstelcoColor.backgroundLight.toColor)
                    }
                .frame(width: 250, height: 56)
                .background(OstelcoColor.primaryButtonBackground.toColor)
                .cornerRadius(27.5)
            }
            ApplePayView(handleError: self.handleError)
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
                    }.background(OstelcoColor.fogAny.toColor)
                    ZStack {
                        VStack {
                            Spacer()
                            OstelcoContainer {
                                VStack(spacing: 20) {
                                    OstelcoTitle(label: "Welcome to OYA!")
                                    Text("Where would you like to use your first 1GB of OYA data?")
                                        .font(.system(size: 21))
                                        .foregroundColor(OstelcoColor.inputLabelAny.toColor)
                                        .multilineTextAlignment(.center )
                                    Button(action: {
                                        self.currentTab = .coverage
                                    }) {
                                        ZStack {
                                            HStack {
                                                Image(systemName: "globe")
                                                    .font(.system(size: 30, weight: .light))
                                                    .foregroundColor(OstelcoColor.backgroundAny.toColor)
                                                Spacer()
                                            }.padding(.leading, 10)
                                            Text("See Available Countries")
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundColor(OstelcoColor.backgroundAny.toColor)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 50)
                                    .background(OstelcoColor.controlTintAny.toColor)
                                    .cornerRadius(27.5)
                                }.padding(25)
                            }
                        }
                        // Lazy way to hide the bottom rounded corners from the above container, a better solution would be to configure the corners in the container itself.
                        VStack {
                            Spacer()
                            Rectangle()
                                .fill(OstelcoColor.backgroundAny.toColor)
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

struct ApplePayView: View {
    
    @EnvironmentObject var store: BalanceStore
    
    let handleError: (_ error: Error) -> Void
    
    var body: some View {
        renderPayment()
    }
    
    private func didFinish() {
        store.selectedProduct = nil
    }
    
    private func didFail(_ error: Error) {
        store.selectedProduct = nil
        handleError(error)
    }
    
    static func canMakePayment() -> ApplePayError? {
        let deviceAllowed = PKPaymentAuthorizationViewController.canMakePayments()
        let cardNetworks: [PKPaymentNetwork] = [.amex, .visa, .masterCard]
        let cardsAllowed = PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: cardNetworks)
        let stripeAllowed = Stripe.deviceSupportsApplePay()
        switch (deviceAllowed, cardsAllowed, stripeAllowed) {
        case (true, true, false):
            return ApplePayError.otherRestrictions
        case (true, false, _):
            return ApplePayError.noSupportedCards
        case (false, _, _):
            return ApplePayError.unsupportedDevice
        case (true, true, true):
            return nil
        }
    }
    
    private func renderPayment() -> AnyView {
        if let product = store.selectedProduct {
            
            if let paymentError = ApplePayView.canMakePayment() {
                didFail(paymentError)
                return AnyView(EmptyView())
            }
            
            if product.canSubmitPaymentRequest {
                return AnyView(PKPaymentAuthorizationViewControllerSwiftUIWrapper(product: product, didFinish: self.didFinish))
            } else {
                didFail(ApplePayError.invalidConfiguration)
            }
        }
        
        return AnyView(EmptyView())
    }
}

struct PKPaymentAuthorizationViewControllerSwiftUIWrapper: UIViewControllerRepresentable {
    func makeCoordinator() -> PKPaymentAuthorizationViewControllerSwiftUIWrapper.Coordinator {
        return Coordinator(self)
    }
    
    typealias UIViewControllerType = PKPaymentAuthorizationViewController
 
    let product: Product
    let didFinish: () -> Void
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<PKPaymentAuthorizationViewControllerSwiftUIWrapper>) -> PKPaymentAuthorizationViewController {
        let vc = PKPaymentAuthorizationViewController(paymentRequest: product.stripePaymentRequest)! // Why do we need to force unwrap?
        vc.delegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: PKPaymentAuthorizationViewController, context: UIViewControllerRepresentableContext<PKPaymentAuthorizationViewControllerSwiftUIWrapper>) {
    }
    
    class Coordinator: NSObject, PKPaymentAuthorizationViewControllerDelegate {
        let parent: PKPaymentAuthorizationViewControllerSwiftUIWrapper
        init(_ parentController: PKPaymentAuthorizationViewControllerSwiftUIWrapper) {
            self.parent = parentController
        }
        
        func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
            // handlePaymentFinished(controller)
            //self.parent.
            self.parent.didFinish() // TODO: Old code differentiates between error and success here based on stored error variable
            /*
             TODO: apple pay dialog is not removed, below is the old code to remove it, but it's not helping in this SwiftUI wrapper
            dismiss(animated: true, completion: {
                self.parent.didFinish()
            })
             */
        }
        
        func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
            // handlePaymentAuthorized(controller, didAuthorizePayment, handler)
            let product = parent.product
            
            // Create Stripe Source.
            STPAPIClient.shared().promiseCreateSource(with: payment)
                .then { source -> Promise<Void> in
                    // Call Prime API to buy the product.
                    let payment = PaymentInfo(sourceID: source.stripeID)
                    return APIManager.shared.primeAPI.purchaseProduct(with: product.sku, payment: payment)
                }
                .done {
                    debugPrint("Successfully bought product \(product.sku)")
                    completion(PKPaymentAuthorizationResult(status: .success, errors: []))
                }
                .catch { error in
                    debugPrint("Failed to buy product with sku %{public}@, got error: %{public}@", "123", "\(error)")
                    ApplicationErrors.log(error)
                    // self.applePayError = self.createPaymentError(error)
                    // TODO: Handle error
                    completion(PKPaymentAuthorizationResult(status: .failure, errors: [error]))
                    // Wait for finish method before we call paymentError()
                }
        }
    }
    
}
