//
//  Country.swift
//  ostelco-ios-client
//
//  Created by mac on 3/14/19.
//  Copyright © 2019 mac. All rights reserved.
//

// Inspired from: https://github.com/juanpablofernandez/CountryList
class Country {

    private static let defaultCodes =  ["DE", "IE", "NO", "SG", "SE", "GB", "US"]
    
    static var defaultCountries: [Country] {
        return self.defaultCodes.map { Country($0) }
    }

    let countryCode: String

    var name: String? {
        return Locale.current.localizedString(forRegionCode: self.countryCode)
    }

    init(_ countryCode: String) {
        self.countryCode = countryCode
    }
}

extension Country: Equatable {
    
    static func == (lhs: Country, rhs: Country) -> Bool {
        return lhs.countryCode == rhs.countryCode
    }
}
