//
//  UITableView+Generics.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 4/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

public extension UITableView {
    
    func dequeue<T: LocatableTableViewCell>(at indexPath: IndexPath) -> T {
        guard let cell = self.dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as? T else {
            fatalError("Could not deque cell with identifier \(T.identifier)")
        }
        
        return cell
    }
}
