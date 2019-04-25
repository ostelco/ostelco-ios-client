//
//  PuchaseHistoryTableViewController.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 24/04/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import Siesta
import ostelco_core

class PurchaseHistoryTableViewCell: UITableViewCell {
    @IBOutlet fileprivate weak var date: UILabel!
    @IBOutlet fileprivate weak var name: UILabel!
    @IBOutlet fileprivate weak var price: UILabel!
}

class PucrhaseHistoryTableViewController: UITableViewController {
    private var records: [PurchaseRecord] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(
            self,
            action: #selector(didPullToRefresh),
            for: .valueChanged
        )
        tableView.refreshControl = refreshControl
        didPullToRefresh()
    }

    @objc func didPullToRefresh() {
        getPurchases { purchases, error in
            self.tableView.refreshControl?.endRefreshing()
            if let error = error {
                debugPrint("error fetching purchases \(error)")
                // TODO: Notify user about this error.
            } else if purchases.isEmpty {
                debugPrint("No purchases available")
                // TODO: Show a message for empty purchase list.
            }
            self.records = purchases
            self.tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PurchaseItem", for: indexPath)
        if let purchaseCell: PurchaseHistoryTableViewCell = cell as? PurchaseHistoryTableViewCell {
            let record = self.records[indexPath.row]
            purchaseCell.name.text = record.name
            purchaseCell.date.text = record.date
            purchaseCell.price.text = record.amount
            return purchaseCell
        } else {
            return cell
        }
    }

    func getPurchases(completionHandler: @escaping ([PurchaseRecord], Error?) -> Void) {
        APIManager.sharedInstance.purchases.load()
            .onSuccess { entity in
                DispatchQueue.main.async {
                    if let purchases: [PurchaseModel] = entity.typedContent(ifNone: nil) {
                        let sortedPurchases = purchases.sorted { $0.timestamp > $1.timestamp }
                        let records = sortedPurchases.map { PurchaseRecord(from: $0) }
                        completionHandler(records, nil)
                    } else {
                        completionHandler([], nil)
                    }
                }
            }
            .onFailure { error in
                DispatchQueue.main.async {
                    completionHandler([], error)
                }
        }
    }
}
