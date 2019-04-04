//
//  Country.swift
//  ostelco-ios-client
//
//  Created by mac on 3/14/19.
//  Copyright © 2019 mac. All rights reserved.
//

// Inspired from: https://github.com/juanpablofernandez/CountryList
public class Country {

    public var countryCode: String

    public var name: String? {
        let current = Locale(identifier: "en_US")
        return current.localizedString(forRegionCode: countryCode) ?? nil
    }

    init(countryCode: String) {
        self.countryCode = countryCode
    }
}
