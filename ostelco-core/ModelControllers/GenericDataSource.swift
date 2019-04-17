//
//  GenericDataSource.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 4/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

/// A generic data source for a single-typed list of objects.
/// NOTE: This class does no view configuration - that should be done in subclasses.
open class GenericDataSource<Item>: NSObject {
    
    /// The list of items driving this table view.
    public var items: [Item]
    
    /// The number of items currently in the list.
    open var numberOfItems: Int {
        return self.items.count
    }
    
    /// Designated initializer
    ///
    /// - Parameter items: [Optional] The items to begin with.
    init(items: [Item]?) {
        self.items = items ?? []
        super.init()
    }
    
    /// Grabs the item at the given index path's row
    /// Note: Will crash if the indexPath is out of bounds.
    ///       If you're not sure whether something will be there, use `optionalItem(at:)`.
    ///
    /// - Parameter indexPath: The index path to fetch an item for
    /// - Returns: The item at that index path
    open func item(at indexPath: IndexPath) -> Item {
        return self.items[indexPath.row]
    }
    
    /// Grabs the item at the given index path's row, if that index exists in `items`.
    /// Otherwise, returns nil
    ///
    /// - Parameter indexPath: The index path to fetch an item for
    /// - Returns: The retrieved item, or nil.
    open func optionalItem(at indexPath: IndexPath) -> Item? {
        guard self.items.indices.contains(indexPath.row) else {
            return nil
        }
        
        return self.item(at: indexPath)
    }
    
    /// Should be called when a given index path is selected.
    ///
    /// - Parameter indexPath: The index path which was selected.
    open func selectedIndexPath(_ indexPath: IndexPath) {
        guard let item = self.optionalItem(at: indexPath) else {
            return
        }
        
        self.selectedItem(item)
    }
    
    // MARK: - Subclasses MUST override
    
    /// An open func to be overridden whan an item is selected
    ///
    /// - Parameter item: The item which was selected.
    open func selectedItem(_ item: Item) {
        fatalError("Subclasses must override this method!")
    }
}
