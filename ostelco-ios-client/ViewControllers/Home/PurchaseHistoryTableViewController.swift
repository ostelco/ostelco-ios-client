//
//  PuchaseHistoryTableViewController.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 24/04/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import UIKit

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
        refreshControl.beginRefreshing()
        didPullToRefresh()
    }

    @objc func didPullToRefresh() {
        APIManager.shared.primeAPI
            .loadPurchases()
            .map { purchaseModels -> [PurchaseRecord] in
                let sortedPurchases = purchaseModels.sorted { $0.timestamp > $1.timestamp }
                return sortedPurchases.map { PurchaseRecord(from: $0) }
            }
            .ensure { [weak self] in
                self?.tableView.refreshControl?.endRefreshing()
            }
            .done { [weak self] purchaseRecords in
                self?.records = purchaseRecords
                self?.tableView.reloadData()
            }
            .catch { error in
                ApplicationErrors.log(error)
                // TODO: Notify user about this error.
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
}
