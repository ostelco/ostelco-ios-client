//
//  PurchaseHistoryTableViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 10/20/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation
import UIKit
import Siesta
import SiestaUI
import os

class PurchaseHistoryTableViewController: UITableViewController, ResourceObserver {
    let statusOverlay = ResourceStatusOverlay()
    var items = [PurchaseModel]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ostelcoAPI.purchases.loadIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        statusOverlay.positionToCoverParent()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 84
        
        statusOverlay.embed(in: self)
        
        ostelcoAPI.purchases
            .addObserver(self)
            .addObserver(statusOverlay)
        
        self.tableView.tableFooterView = UIView(frame: .zero)
    }
    
    func resourceChanged(_ resource: Resource, event: ResourceEvent) {
            
        // TODO: Handle below errors in a better way
        guard let purchases = resource.jsonArray as? [PurchaseModel] else {
            os_log("Resource changed but returned data was empty for PurchaseModel.")
            return
        }
        
        dump(purchases)
        
        self.items = purchases
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PurchaseHistoryTableViewCell") as? PurchaseHistoryTableViewCell else {
            fatalError("The dequeued cell is not an instance of PurchaseHistoryTableViewCell")
        }
        let item = self.items[(indexPath as NSIndexPath).row]
        
        // TODO: Move date formatter to helper function in helper file
        let date = Date(timeIntervalSince1970: TimeInterval(item.timestamp / 1000))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd MMMM YYYY" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        
        cell.timestampLabel.text = strDate
        cell.productLabel.text = item.product.presentation.label
        cell.priceLabel.text = item.product.presentation.price
        
        return cell
    }
}
