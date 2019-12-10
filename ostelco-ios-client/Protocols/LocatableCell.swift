//
//  LocatableCell.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

/// Where is a cell created?
///
/// - code: The cell is created in code.
/// - nib: The cell is created in a free-floating .xib file. Parameter is a `UINib` pointing to this file.
/// - storyboard: The cell is created in a storyboard.
public enum CellLocation {
    case code
    case nib(_: UINib)
    case storyboard
}

/// A cell which knows where its underlying UI implementation is located.
public protocol LocatableCell: Identifiable {
    
    /// The location of the cell
    static var location: CellLocation { get }
}

// MARK: - NibLoadable Default Implementation

public extension LocatableCell where Self: NibLoadable {
    
    static var location: CellLocation {
        return .nib(self.nib)
    }
}

// MARK: - UITableViewCell Default implementation

public typealias LocatableTableViewCell = LocatableCell & UITableViewCell

public extension LocatableCell where Self: UITableViewCell {
    
    /// Performs any necessary registration of the cell with the table view based on where it's located.
    ///
    /// - Parameter tableView: The table view to register with.
    static func registerIfNeeded(with tableView: UITableView) {
        switch self.location {
        case .storyboard:
            // Not necessary to register
            break
        case .nib(let nib):
            tableView.register(nib, forCellReuseIdentifier: self.identifier)
        case .code:
            tableView.register(self, forCellReuseIdentifier: self.identifier)
        }
    }
}

// MARK: - UICollectionViewCell Default Implementation

public typealias LocatableCollectionViewCell = LocatableCell & UICollectionViewCell

public extension LocatableCell where Self: UICollectionViewCell {
    
    /// Performs any necessary registration of the cell with the collection view based on where it's located.
    ///
    /// - Parameter collectionView: The collection view to register with.
    static func registerIfNeeded(with collectionView: UICollectionView) {
        switch self.location {
        case .storyboard:
            // Not necessary to register
            break
        case .nib(let nib):
            collectionView.register(nib, forCellWithReuseIdentifier: self.identifier)
        case .code:
            collectionView.register(self, forCellWithReuseIdentifier: self.identifier)
        }
    }
}
