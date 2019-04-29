//
//  MyInfoDetails.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 11/04/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

struct MyInfoAddress: Codable {
    let country: String?
    let unit: String?
    let street: String?
    let block: String?
    let postal: String?
    let floor: String?
    let building: String?
    
    func getAddressLine1() -> String {
        var addressLine1: String = ""
        if let block = self.block {
            addressLine1 = "\(block) "
        }
        if let street = self.street {
            addressLine1 += "\(street) "
        }
        return addressLine1
    }
    
    func getAddressLine2() -> String {
        var addressLine2: String = ""
        if let postal = self.postal {
            addressLine2 = "\(postal) "
        }
        if let country = self.country {
            addressLine2 += "\(country) "
        }
        return addressLine2
    }
}

struct MyInfoDetails: Codable {
    private let _name: MyInfoRequiredValue
    var name: String {
        return _name.value
    }
    
    private let _dob: MyInfoRequiredValue
    var dob: String {
        return _dob.value
    }
    private let _email: MyInfoRequiredValue
    var email: String {
        return _email.value
    }
    
    private let _sex: MyInfoOptionalValue?
    var sex: String? {
        return _sex?.value
    }
    
    private let _residentialStatus: MyInfoOptionalValue?
    var residentialStatus: String? {
        return _residentialStatus?.value
    }
    
    private let _nationality: MyInfoOptionalValue?
    var nationality: String? {
        return _nationality?.value
    }
    
    var address: MyInfoAddress
    let mobileNumber: MyInfoMobileNumber?
    
    enum CodingKeys: String, CodingKey {
        case _name = "name"
        case _dob = "dob"
        case _email = "email"
        case address = "regadd"
        case _sex = "sex"
        case _residentialStatus = "residentialstatus"
        case _nationality = "nationality"
        case mobileNumber = "mobileno"
    }
}

struct MyInfoRequiredValue: Codable {
    let value: String
}

struct MyInfoOptionalValue: Codable {
    let value: String?
}

struct MyInfoMobileNumber: Codable {
    let number: String?
    let code: String?
    let prefix: String?
    
    enum CodingKeys: String, CodingKey {
        case number = "nbr"
        case code
        case prefix
    }
    
    var formattedNumber: String? {
        guard
            let number = self.number,
            let code = self.code,
            let prefix = self.prefix else {
                return nil
        }
        
        return "\(prefix)\(code)\(number)"
    }
}
