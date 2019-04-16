//
//  LocatableCell.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

/// Where is a UITableViewCell created?
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
    static var location: CellLocation { get }
}

// MARK: - Default implementation

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
            tableView.register(Self.self, forCellReuseIdentifier: self.identifier)
        }
    }
}
