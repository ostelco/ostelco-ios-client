//
//  LocatableCell.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

enum CellLocation {
    case code
    case nib(_: UINib)
    case storyboard
}

protocol LocatableCell: UITableViewCell, Identifiable {
    static var location: CellLocation { get }
}

extension LocatableCell {
    
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

