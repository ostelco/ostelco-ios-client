//
//  HomeViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 10/18/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import Siesta
import SiestaUI
import Foundation
import os
import Stripe
import Bugsee

enum HomeErrors: Error {
    case failedToTransformBundlesToModel
    case failedToTransformProductsToModel
    case unknownResource
    case bundlesIsEmpty
    case productsIsEmpty
    case noDefaultProductFound
    case applePayDeviceNotSupported
    case applePayUserHasNoValidCardsInWallet
    case applePayCouldNotSubmitPaymentRequest
    case stripeReturnedSourceIsEmpty
}
class HomeViewController: UIViewController, ResourceObserver, PKPaymentAuthorizationViewControllerDelegate {

    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var balanceText: UILabel!
    @IBOutlet weak var productButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var paymentSucceeded = false;
    
    var product: ProductModel?;
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        ostelcoAPI.bundles.load().onCompletion({_ in
            refreshControl.endRefreshing()
        })
    }   
    
    // TODO: Customize text in status overlay to reflect error message
    let statusOverlay = ResourceStatusOverlay()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ostelcoAPI.bundles.loadIfNeeded()
        ostelcoAPI.products.loadIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        statusOverlay.positionToCoverParent()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        balanceLabel.isHidden = true
        balanceLabel.textColor = ThemeManager.currentTheme().mainColor
        balanceText.textColor = ThemeManager.currentTheme().mainColor
        
        productButton.isHidden = true
        Bugsee.trace(key: "productButtonIsHidden", value: true)
        
        statusOverlay.embed(in: self)
        
        // TODO: Figure out how to handle case where bundles API fails
        ostelcoAPI.bundles
            .addObserver(self)
            .addObserver(statusOverlay)
        
        // TODO: Figure out how to handle case where products API fails
        ostelcoAPI.products
            .addObserver(self)
            .addObserver(statusOverlay)
        
        let refreshControl = scrollView.addRefreshControl(target: self,
                                                          action: #selector(handleRefresh(_:)))
        refreshControl.tintColor = ThemeManager.currentTheme().mainColor
        
        refreshControl.attributedTitle =
            NSAttributedString(string: "Refresh balance",
                               attributes: [
                                NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme().mainColor,
                                NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-UltraLight",
                                                                   size: 36.0)! ])
        self.scrollView.alwaysBounceVertical = true
    }
    
    func converByteToGB(_ bytes:Int64) -> String {
        let formatter:ByteCountFormatter = ByteCountFormatter()
        formatter.countStyle = .decimal
        formatter.zeroPadsFractionDigits = true
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    func productsChanged(products: [ProductModel]) {
        
        if products.count > 0 {
            let filteredProducts = products.filter { $0.presentation.isDefault == "true" }
            if filteredProducts.count < 1 {
                Bugsee.logError(error: HomeErrors.noDefaultProductFound)
                productButton.isHidden = true
                
            } else {
                product = filteredProducts[0]
                productButton.setTitle("\(product!.presentation.label) \(product!.presentation.price)", for: .normal)
                productButton.isHidden = false
            }
        } else {
            Bugsee.logError(error: HomeErrors.productsIsEmpty)
            productButton.isHidden = false
        }
        
        
        Bugsee.trace(key: "productButtonIsHidden", value: productButton.isHidden)
    }
    
    func bundlesChanged(bundles: [BundleModel]) {
        if bundles.count > 0 {
            let bundle = bundles[0]
            balanceLabel.text = self.converByteToGB(bundle.balance)
            balanceLabel.isHidden = false
        } else {
            Bugsee.logError(error: HomeErrors.bundlesIsEmpty)
            balanceLabel.isHidden = true
        }
        Bugsee.trace(key: "balanceLabelIsHidden", value: balanceLabel.isHidden)
    }
    
    func resourceChanged(_ resource: Resource, event: ResourceEvent) {
        
        switch (resource.url) {
        case ostelcoAPI.bundles.url:
            if let bundles = resource.jsonArray as? [BundleModel] {
              self.bundlesChanged(bundles: bundles)
            } else {
                Bugsee.logError(error: HomeErrors.failedToTransformBundlesToModel)
                Bugsee.trace(key: "balanceLabelIsHidden", value: true)
                balanceLabel.isHidden = true
            }
        case ostelcoAPI.products.url:
            if let products = resource.jsonArray as? [ProductModel] {
                self.productsChanged(products: products)
            } else {
                Bugsee.logError(error: HomeErrors.failedToTransformProductsToModel)
                Bugsee.trace(key: "productButtonIsHidden", value: true)
                productButton.isHidden = true
            }
        default:
            Bugsee.logError(error: HomeErrors.unknownResource)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func topUp(_ sender: Any) {
        self.handleApplePayButtonTapped();
    }
    
    func handleApplePayButtonTapped() {
        Bugsee.event("payment_button_clicked", params: [
            "country": "SG",
            "currency": product!.price.currency,
            "label": product!.presentation.label,
            "amount": "\(product!.price.amount)",
            "sku": product!.sku
            ])
        
        let merchantIdentifier = Environment().configuration(.AppleMerchantId)
        
        os_log("Merchant identifier: %{public}@ country: SG currency: %{public}@ label: %{public}@ amount: %{public}@", merchantIdentifier, product!.price.currency, product!.presentation.label, "\(product!.price.amount)")
        let paymentRequest = Stripe.paymentRequest(withMerchantIdentifier: merchantIdentifier, country: "SG", currency: product!.price.currency)
        
        os_log("device supports apple pay: %{public}@", "\(Stripe.deviceSupportsApplePay())")
        os_log("can make payment: %{public}@", "\(PKPaymentAuthorizationViewController.canMakePayments())")
        
        if (!Stripe.deviceSupportsApplePay()) {
            self.showAlert(title: "Payment Error", msg: "Device not supported.")
            Bugsee.logError(error: HomeErrors.applePayDeviceNotSupported)
            return
        }
        if (!PKPaymentAuthorizationViewController.canMakePayments()) {
            self.showAlert(title: "Payment Error", msg: "Wallet empty or does not contain any of the supported card types. Should give user option to open apple wallet to add a card.")
            Bugsee.logError(error: HomeErrors.applePayUserHasNoValidCardsInWallet)
            return
        }
        // Configure the line items on the payment request
        paymentRequest.paymentSummaryItems = [
            PKPaymentSummaryItem(label: self.product!.presentation.label, amount: Decimal(Double(self.product!.price.amount) / 100.0) as NSDecimalNumber),
            // The final line should represent your company;
            // it'll be prepended with the word "Pay" (i.e. "Pay iHats, Inc $50")
            // PKPaymentSummaryItem(label: "iHats, Inc", amount: 50.00),
        ]
        
        Bugsee.setAttribute("device_can_submit_payment_request", value: Stripe.canSubmitPaymentRequest(paymentRequest))
        // Continued in next step
        if Stripe.canSubmitPaymentRequest(paymentRequest) {
            Bugsee.event("payment_apple_pay_dialog_initiated")
            // Setup payment authorization view controller
            let paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
            paymentAuthorizationViewController!.delegate = self
            
            // Present payment authorization view controller
            present(paymentAuthorizationViewController!, animated: true)
        }
        else {
            // There is a problem with your Apple Pay configuration
            os_log("There is a problem with your Apple Pay configuration")
            // TODO: Report error to bug reporting system
            #if DEBUG
            #if targetEnvironment(simulator)
            self.showAlert(title: "There is a problem with your Apple Pay configuration", msg: "Apple pay in test mode on simulator is supposed to work. Don't know why it failed.")
            #else
            self.showAlert(title: "There is a problem with your Apple Pay configuration", msg: "Apple pay in test mode on real devices has not been tested yet.")
            #endif
            #else
            #if targetEnvironment(simulator)
            self.showAlert(title: "There is a problem with your Apple Pay configuration", msg: "Apple pay in production mode on simulator does not work.")
            #else
            self.showAlert(title: "There is a problem with your Apple Pay configuration", msg: "Apple pay in production mode failed for unknown reason.")
            #endif
            #endif
            Bugsee.event("payment_could_not_be_initiated")
            Bugsee.logError(error: HomeErrors.applePayCouldNotSubmitPaymentRequest)
        }
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        STPAPIClient.shared().createSource(with: payment) { (source: STPSource?, error: Error?) in
            
            if let error = error {
                self.showAlert(title: "Failed to create stripe source", msg: "\(error.localizedDescription)")
                Bugsee.logError(error: error)
            } else {
                if let source = source {
                    ostelcoAPI.products.child(self.product!.sku).child("purchase").withParam("sourceId", source.stripeID).request(.post)
                        .onProgress({ progress in
                            os_log("Progress %{public}@", "\(progress)")
                        })
                        .onSuccess({ result in
                            Bugsee.event("payment_succeeded")
                            os_log("Successfully bought a product %{public}@", "\(result)")
                            ostelcoAPI.purchases.invalidate()
                            ostelcoAPI.bundles.invalidate()
                            ostelcoAPI.bundles.load()
                            self.paymentSucceeded = true
                            completion(.success)
                        })
                        .onFailure({ error in
                            // TODO: Report error to server
                            // TODO: fix use of insecure unwrapping, can cause application to crash
                            Bugsee.event("purchase_failed")
                            Bugsee.logError(error: error)
                            os_log("Failed to buy product with sku %{public}@, got error: %{public}@", self.product!.sku, "\(error)")
                            self.showAlert(title: "Failed to buy product with ostelcoAPI", msg: "\(error.localizedDescription)")
                            self.paymentSucceeded = false
                            completion(.failure)
                        })
                        .onCompletion({ _ in
                            // UIViewController.removeSpinner(spinner: sv)
                        })
                } else {
                    self.showAlert(title: "Failed to create stripe source", msg: "Contact support")
                    Bugsee.logError(error: HomeErrors.stripeReturnedSourceIsEmpty)
                }
            }
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        // Dismiss payment authorization view controller
        dismiss(animated: true, completion: {
            if (self.paymentSucceeded) {
                // Show a receipt page...
                os_log("Show receipt page?")
            }
        })
    }
}

