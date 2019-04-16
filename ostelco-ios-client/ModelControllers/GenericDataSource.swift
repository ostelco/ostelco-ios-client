//
//  GenericDataSource.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import UIKit
import ostelco_core

class GenericTableViewDataSource<Item, Cell: LocatableCell>: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    private weak var tableView: UITableView?
    var items: [Item]
    
    init(tableView: UITableView, items: [Item]?) {
        self.tableView = tableView
        self.items = items ?? []
        
        super.init()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        Cell.registerIfNeeded(with: tableView)
    }
    
    func item(at indexPath: IndexPath) -> Item {
        return self.items[indexPath.row]
    }
    
    // MARK: - Subclasses MUST override these
    
    func selectedItem(_ item: Item) {
        fatalError("Subclasses must override this method!")
    }
    
    func configureCell(_ cell: Cell, for item: Item) {
        fatalError("Subclasses must override this method!")
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Cell.identifier, for: indexPath) as? Cell else {
            assertionFailure("Could not dequeue cell with identifier \(Cell.identifier)")
            return UITableViewCell()
        }
        
        let item = self.item(at: indexPath)
        self.configureCell(cell, for: item)
        
        return cell
    }
    
    // MARK - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = self.item(at: indexPath)
        self.selectedItem(item)
    }
}
