//
//  CountryCell.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import UIKit

final class CountryCell: UITableViewCell {
    
    @IBOutlet private(set) var countryLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.countryLabel.text = nil
    }
}

// MARK: - Mix-in extensions

extension CountryCell: NibLoadable { /* mix-in */ }

// MARK: - LocatableCell

extension CountryCell: LocatableCell {
    
    static var location: CellLocation {
        return .nib(self.nib)
    }
}
