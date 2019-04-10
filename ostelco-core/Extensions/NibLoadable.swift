//
//  NibLoadable.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 4/10/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

public protocol NibLoadable: class {
    static var nibName: String { get }
    static var nib: UINib { get }
    static var bundle: Bundle { get }
    
    static var fromNib: Self { get }
}

public extension NibLoadable {
    
    static var nibName: String {
        return String(describing: self)
    }
    
    static var bundle: Bundle {
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
