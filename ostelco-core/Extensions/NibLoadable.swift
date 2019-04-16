//
//  NibLoadable.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 4/10/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

/// A protocol representing an object which can be loaded from a UINib.
public protocol NibLoadable: class {
    
    /// The name of the nib, without the extension.
    static var nibName: String { get }
    
    /// The nib object itself
    static var nib: UINib { get }
    
    /// The bundle where the nib lives
    static var bundle: Bundle { get }
    
    /// The instantiated `NibLoadable` object.
    /// Note: Throws a fatal error if it cannot be loaded as the first object in the given nib.
    static var fromNib: Self { get }
}

// MARK: - Default Implementation

public extension NibLoadable {
    
    static var nibName: String {
        // The nib has the same name as the class
        return String(describing: self)
    }
    
    static var bundle: Bundle {
        // The nib is in the same bundle as the class
        return Bundle(for: self)
    }
    
    static var nib: UINib {
        return UINib(nibName: self.nibName, bundle: self.bundle)
    }
    
    static var fromNib: Self {
        let objectsInNib = self.nib.instantiate(withOwner: nil, options: nil)
        guard let firstObject = objectsInNib.first as? Self else {
            fatalError("The first object in \(self.nibName).xib was not a \(String(describing: self))")
        }
        
        return firstObject
    }
}
