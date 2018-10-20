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

class HomeViewController: UIViewController, ResourceObserver {

    @IBOutlet weak var balanceLabel: UILabel!
    
    // TODO: Customize text in status overlay to reflect error message
    let statusOverlay = ResourceStatusOverlay()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ostelcoAPI.bundles.loadIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        statusOverlay.positionToCoverParent()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusOverlay.embed(in: self)
        
        ostelcoAPI.bundles
            .addObserver(self)
            .addObserver(statusOverlay)
    }
    
    func converByteToGB(_ bytes:Int64) -> String {
        let formatter:ByteCountFormatter = ByteCountFormatter()
        formatter.countStyle = .decimal
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    func resourceChanged(_ resource: Resource, event: ResourceEvent) {
        
        // TODO: Handle below errors in a better way
        guard let bundles = resource.jsonArray as? [BundleModel] else {
            print("Error: Could not cast response to model...")
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


}

