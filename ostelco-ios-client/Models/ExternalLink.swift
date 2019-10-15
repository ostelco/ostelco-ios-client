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
    case esimInstructionsVideo = "https://pi-redirector.firebaseapp.com/esim-instructions-video"
    case minimumAgeDetails = "https://pi-redirector.firebaseapp.com/minimum-age"
    case locationRequirement = "https://pi-redirector.firebaseapp.com/location-required"
    case aboutMembership = "https://pi-redirector.firebaseapp.com/about-membership"
    case currentPricing = "https://pi-redirector.firebaseapp.com/current-pricing"
    case fullyDigital = "https://pi-redirector.firebaseapp.com/fully-digital"
    case oyaWebpage = "https://oya.sg"
    
    var url: URL {
        guard let url = URL(string: self.rawValue) else {
            fatalError("Could not create URL from \(self.rawValue)")
        }
        
        return url
    }
}
