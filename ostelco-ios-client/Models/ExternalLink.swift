//
//  ExternalLink.swift
//  ostelco-ios-client
//
//  Created by mac on 5/7/19.
//  Copyright © 2019 mac. All rights reserved.
//

enum ExternalLink: String, CaseIterable {
    case privacyPolicy = "https://pi-redirector.firebaseapp.com/privacy-policy"
    case termsAndConditions = "https://pi-redirector.firebaseapp.com/terms-and-conditions"
    
    var url: URL {
        guard let url = URL(string: self.rawValue) else {
            fatalError("Could not create URL from \(self.rawValue)")
        }
        
        return url
    }
}
