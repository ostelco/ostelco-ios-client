//
//  OnBoardingManager.swift
//  ostelco-ios-client
//
//  Created by mac on 3/14/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core

class OnBoardingManager {
    static let sharedInstance = OnBoardingManager()
    var selectedCountry = Country("SG")
    var region: RegionResponse? {
        didSet {
            if let region = region {
                let countryName = region.region.name
                Freshchat.sharedInstance()?.setUserPropertyforKey("region", withValue: region.region.name)
                Freshchat.sharedInstance()?.setUserPropertyforKey("\(countryName)-Status", withValue: region.status.rawValue)
                Freshchat.sharedInstance()?.setUserPropertyforKey("\(countryName)-JumioStatus", withValue: region.kycStatusMap.JUMIO?.rawValue)
                Freshchat.sharedInstance()?.setUserPropertyforKey("\(countryName)-addrAndPhone", withValue: region.kycStatusMap.ADDRESS_AND_PHONE_NUMBER?.rawValue)
                Freshchat.sharedInstance()?.setUserPropertyforKey("\(countryName)-MyInfoStatus", withValue: region.kycStatusMap.MY_INFO?.rawValue)
                Freshchat.sharedInstance()?.setUserPropertyforKey("\(countryName)-NricFinStatus", withValue: region.kycStatusMap.NRIC_FIN?.rawValue)
            }
        }
    }
}
