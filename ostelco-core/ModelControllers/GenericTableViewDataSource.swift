//
//  GenericDataSource.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import UIKit

/// A generic `UITableViewDataSource` superclass which handles registration of cells and selection.
///
/// Subclasses must override indicated methods to configure a cell and handle selection of an item.
///
/// Generics:
///     Item: Can be any type of item.
///     Cell: Must be a `UITableViewCell` subclass which conforms to `LocatableCell` and `Identifiable`.
open class GenericTableViewDataSource<Item, Cell: LocatableTableViewCell>: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    private weak var tableView: UITableView?
    public var items: [Item]
    
    public init(tableView: UITableView, items: [Item]?) {
        self.tableView = tableView
        self.items = items ?? []
        
        super.init()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        Cell.registerIfNeeded(with: tableView)
    }
    
    open func reloadData() {
        self.tableView?.reloadData()
    }
    
    open func item(at indexPath: IndexPath) -> Item {
        return self.items[indexPath.row]
    }
    
    // MARK: - Subclasses MUST override these
    
    open func selectedItem(_ item: Item) {
        fatalError("Subclasses must override this method!")
    }
    
    open func configureCell(_ cell: Cell, for item: Item) {
        fatalError("Subclasses must override this method!")
    }
    
    // MARK: - UITableViewDataSource
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Cell.identifier, for: indexPath) as? Cell else {
            assertionFailure("Could not dequeue cell with identifier \(Cell.identifier)")
            return UITableViewCell()
        }
        
        let item = self.item(at: indexPath)
        self.configureCell(cell, for: item)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = self.item(at: indexPath)
        self.selectedItem(item)
    }
}
