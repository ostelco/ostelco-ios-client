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
/// Subclasses must override:
///     GenericDataSource.selectedItem(_)
///     GenericTableViewDataSource.configureCell(_,for:)
///
/// Generics:
///     Item: Can be any type of item.
///     Cell: Must be a `UITableViewCell` subclass which conforms to `LocatableCell` and `Identifiable`.
open class GenericTableViewDataSource<Item, Cell: LocatableTableViewCell>: GenericDataSource<Item>, UITableViewDataSource, UITableViewDelegate {
    
    private weak var tableView: UITableView?
    
    /// Designated initializer
    ///
    /// - Parameters:
    ///   - tableView: The table view you wish to drive with this data source
    ///   - items: [Optional] The items to display.
    public init(tableView: UITableView, items: [Item]?) {
        self.tableView = tableView
        super.init(items: items)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        Cell.registerIfNeeded(with: tableView)
    }
    
    /// Reloads the data in the table view.
    open func reloadData() {
        self.tableView?.reloadData()
    }

    // MARK: - Subclasses MUST override
    
    open func configureCell(_ cell: Cell, for item: Item) {
        fatalError("Subclasses must override this method!")
    }
    
    // MARK: - UITableViewDataSource
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfItems
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: Cell = tableView.dequeue(at: indexPath)
        
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
