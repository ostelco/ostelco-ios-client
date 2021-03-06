//
//  Country.swift
//  ostelco-ios-client
//
//  Created by mac on 3/14/19.
//  Copyright © 2019 mac. All rights reserved.
//

// Inspired from: https://github.com/juanpablofernandez/CountryList
public class Country: Equatable {
    public let countryCode: String
    
    public var name: String? {
        return Locale.current.localizedString(forRegionCode: self.countryCode)
    }
    
    public var nameOrPlaceholder: String {
        return self.name ?? "(Unknown)"
    }
    
    public init(_ countryCode: String) {
        self.countryCode = countryCode
    }

    public var threeLetterCountryCode: String? {
        switch self.countryCode.lowercased() {
        case "sg":
            return "SGP"
        case "no":
            return "NOR"
        case "us":
            return "USA"
        case "my":
            return "MYS"
        default:
            // TODO: Get a full mapping of 2 digit to 3 digit codes for Jumio
            // https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3
            return nil
        }
    }
    
    static func singapore() -> Country {
        return Country("sg")
    }

    // MARK: - Equatable
    
    public static func == (lhs: Country, rhs: Country) -> Bool {
        return lhs.countryCode.lowercased() == rhs.countryCode.lowercased()
    }
}
