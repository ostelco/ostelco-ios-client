//
//  CountryHelper.swift
//  ostelco-core
//
//  Created by mac on 8/15/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

// Struct is completely based on SO: https://stackoverflow.com/questions/11576947/ios-convert-iso-alpha-2-to-alpha-3-country-code
// with an extension to convert from alpha 3 to alpha 2.
public struct CountryHelper {
    
    public static func loadCountryListISO2() -> [String: String]? {
        return loadCountryListISO("ISO-3166-2-to-ISO-3166-3")
    }
    
    public static func loadCountryListISO3() -> [String: String]? {
        return loadCountryListISO("ISO-3166-3-to-ISO-3166-2")
    }
    
    static private func loadCountryListISO(_ resourceName: String) -> [String: String]? {
        
        let pListFileURL = Bundle.main.url(forResource: resourceName, withExtension: "plist", subdirectory: "")
        if let pListPath = pListFileURL?.path,
            let pListData = FileManager.default.contents(atPath: pListPath) {
            do {
                let pListObject = try PropertyListSerialization.propertyList(from: pListData, options: PropertyListSerialization.ReadOptions(), format: nil)
                
                guard let pListDict = pListObject as? [String: String] else {
                    return nil
                }
                
                return pListDict
            } catch {
                print("Error reading regions plist file: \(error)")
                return nil
            }
        }
        return nil
    }
    
    /// Convertion ISO 3166-1-Alpha3 to Alpha2
    /// Country code of 3 letters to 2 letters code
    /// E.g: PRT to PT
    public static func getCountryCodeAlpha3(countryCodeAlpha2: String) -> String? {
        
        guard let countryList = CountryHelper.loadCountryListISO2() else {
            return nil
        }
        
        if let countryCodeAlpha3 = countryList[countryCodeAlpha2] {
            return countryCodeAlpha3
        }
        return nil
    }
    
    /// Convertion ISO 3166-1-Alpha2 to Alpha3
    /// Country code of 2 letters to 3 letters code
    /// E.g: PT to PRT
    public static func getCountryCodeAlpha2(countryCodeAlpha3: String) -> String? {
        
        guard let countryList = CountryHelper.loadCountryListISO3() else {
            return nil
        }
        
        if let countryCodeAlpha2 = countryList[countryCodeAlpha3] {
            return countryCodeAlpha2
        }
        return nil
    }
    
    public static func getLocalCountryCode() -> String? {
        
        guard let countryCode = NSLocale.current.regionCode else { return nil }
        return countryCode
    }
    
    /// This function will get full country name based on the phone Locale
    /// E.g. Portugal
    public static func getLocalCountry() -> String? {
        
        let countryLocale = NSLocale.current
        guard let countryCode = countryLocale.regionCode else { return nil }
        let country = (countryLocale as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: countryCode)
        return country
    }
}
