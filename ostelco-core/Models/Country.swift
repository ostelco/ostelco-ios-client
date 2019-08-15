//
//  Country.swift
//  ostelco-ios-client
//
//  Created by mac on 3/14/19.
//  Copyright © 2019 mac. All rights reserved.
//

// Inspired from: https://github.com/juanpablofernandez/CountryList
public class Country: Equatable {
    
    private static let defaultCodes =  ["NO", "SG", "US"]
    
    public static var defaultCountries: [Country] {
        return self.defaultCodes.map { Country($0) }
    }
    
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
        return CountryHelper.countryCodeAlpha3FromAlpha2(countryCodeAlpha2: countryCode.uppercased())?.uppercased()
    }

    // MARK: - Equatable
    
    public static func == (lhs: Country, rhs: Country) -> Bool {
        return lhs.countryCode.lowercased() == rhs.countryCode.lowercased()
    }
}
