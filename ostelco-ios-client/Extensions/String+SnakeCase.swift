//
//  String+SnakeCase.swift
//  ostelco-ios-client
//
//  Created by mac on 4/29/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

// Found it on the internet: https://gist.github.com/dmsl1805/ad9a14b127d0409cf9621dc13d237457
extension String {
    
    func snakeCased() -> String? {
        let pattern = "([a-z0-9])([A-Z])"
        
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: count)
        return regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2").lowercased()
    }
}
