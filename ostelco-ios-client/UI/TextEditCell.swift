//
//  AddressEditCell.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/29/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

final class TextEditCell: UITableViewCell {
    
    @IBOutlet private(set) var textField: UITextField!
}

// MARK: - Mix-in extensions

extension TextEditCell: NibLoadable { /* mix-in */ }
extension TextEditCell: LocatableCell { /* mix-in */ }
