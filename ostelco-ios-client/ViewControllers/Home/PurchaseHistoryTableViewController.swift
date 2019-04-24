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

class PurchaseRecord {
    let name: String
    let amount: String
    let date: String

    init(name: String, amount: String, date: String) {
        self.name = name
        self.amount = amount
        self.date = date
    }
}

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
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        didPullToRefresh()
    }

    @objc func didPullToRefresh() {
        getPurchases { purchases, error in
            self.tableView.refreshControl?.endRefreshing()
            if let error = error {
                print("error fetching purchases \(error)")
            } else if purchases.isEmpty {
                print("No purchases available")
            }
            self.records = purchases
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        APIManager.sharedInstance.purchases.load()
            .onSuccess { entity in
                DispatchQueue.main.async {
                    if let purchases: [PurchaseModel] = entity.typedContent(ifNone: nil) {
                        let records: [PurchaseRecord] = purchases.map {
                            let date = Date(timeIntervalSince1970: (Double($0.timestamp) / 1000.0))
                            let strDate = dateFormatter.string(from: date)
                            return PurchaseRecord(
                                name: $0.product.presentation.label,
                                amount: $0.product.presentation.price,
                                date: strDate
                            )
                        }
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
