//
//  UITableView+Footer.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

extension UITableView {
    
    /// Adds an empty `tableFooterView` to prevent separator lines from showing beyond the length of a given list.
    func addEmptyFooter() {
        self.tableFooterView = UIView()
    }
}
