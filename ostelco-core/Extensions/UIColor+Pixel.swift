//
//  UIColor+Pixel.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 4/23/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

public extension UIColor {
    
    /// Produces a 1pt x 1pt image suitable for making the background image for various states of UIButtons.
    var toPixelImage: UIImage {
        // How big does this all need to be?
        let origin = CGPoint.zero
        let size = CGSize(width: 1, height: 1)
        let rect = CGRect(origin: origin, size: size)

        // Actually try to draw things!
        UIGraphicsBeginImageContext(size)
        guard let context = UIGraphicsGetCurrentContext() else {
            fatalError("Couldn't get current graphics context?!")
        }
        
        context.setFillColor(self.cgColor)
        context.fill(rect)
        
        // This will exectue whenever the code below exits.
        defer {
            UIGraphicsEndImageContext()
        }
        
        // Make sure we actually drew something
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            fatalError("Couldn't get image from context? Wat?")
        }
    
        // ZOMG it worked!
        return image
    }
}
