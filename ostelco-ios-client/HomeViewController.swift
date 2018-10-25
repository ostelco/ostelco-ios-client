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

class HomeViewController: UIViewController, ResourceObserver {

    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var productButton: UIButton!
    
    var product: ProductModel?;
    
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
        
        productButton.isHidden = true
        productButton.layer.cornerRadius = 22.5
        productButton.addShadow(offset: CGSize(width: 0.0, height: 15.0), color: UIColor(red: 0, green: 68.0/255.0, blue: 166.0/255.0, alpha: 0.35), radius: 18.0, opacity: 1)
        
        statusOverlay.embed(in: self)
        
        // TODO: Figure out how to handle case where bundles API fails
        ostelcoAPI.bundles
            .addObserver(self)
            .addObserver(statusOverlay)
        
        // TODO: Figure out how to handle case where products API fails
        ostelcoAPI.products
            .addObserver(self)
            .addObserver(statusOverlay)
    }
    
    func converByteToGB(_ bytes:Int64) -> String {
        let formatter:ByteCountFormatter = ByteCountFormatter()
        formatter.countStyle = .decimal
        formatter.zeroPadsFractionDigits = true
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    func resourceChanged(_ resource: Resource, event: ResourceEvent) {
        
        // TODO: Handle below errors in a better way
        guard let bundles = resource.jsonArray as? [BundleModel] else {
            print("Error: Could not cast response to model...")
            
            guard var products = resource.jsonArray as? [ProductModel] else {
                print("Error: Could not cast response to model...")
                productButton.isHidden = true
                return
            }
            
            dump(products)
            
            products = products.filter { $0.presentation.isDefault == "true" }
            
            dump(products)
            
            if products.count < 1 {
                print("Error: Could not find a default product.")
                productButton.isHidden = true
            } else {
                product = products[0]
                productButton.isHidden = false
                productButton.setTitle("\(product!.presentation.label) \(product!.presentation.price)", for: .normal)
            }
            return
        }
        
        if bundles.count < 1 {
            print("Error: Could not find any bundles")
        } else {
            let bundle = bundles[0]
            balanceLabel.text = self.converByteToGB(bundle.balance)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func topUp(_ sender: Any) {
        let sv = UIViewController.displaySpinner(onView: self.view)
        ostelcoAPI.products.child(self.product!.sku).request(.post)
            .onProgress({ progress in
                print("Progress \(progress)")
            })
            .onSuccess({ result in
                os_log("Successfully bought a product %{public}@", "\(result)")
                ostelcoAPI.purchases.invalidate()
                ostelcoAPI.bundles.invalidate()
                ostelcoAPI.bundles.load()
            })
            .onFailure({ error in
                // TODO: Report error to server
                // TODO: fix use of insecure unwrapping, can cause application to crash
                os_log("Failed to buy product with sku %{public}@, got error: %{public}@", self.product!.sku, "\(error)")
                let alert = UIAlertController(title: "Alert", message: "Failed to buy product. \(error.httpStatusCode!) \(error.userMessage)", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    switch action.style{
                    case .default:
                        print("default")
                        
                    case .cancel:
                        print("cancel")
                        
                    case .destructive:
                        print("destructive")
                        
                        
                    }}))
                self.present(alert, animated: true, completion: nil)
            })
            .onCompletion({ _ in
                UIViewController.removeSpinner(spinner: sv)
            })
        
        // TODO: invalidate purchases resource after purchase
    }
    
}

