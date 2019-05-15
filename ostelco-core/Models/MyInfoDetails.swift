//
//  MyInfoDetails.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 11/04/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

public struct MyInfoAddress: Codable {
    public let country: String?
    public let unit: String?
    public let street: String?
    public let block: String?
    public let postal: String?
    public let floor: String?
    public let building: String?
    
    public init(country: String?,
                unit: String?,
                street: String?,
                block: String?,
                postal: String?,
                floor: String?,
                building: String?) {
        self.country = country
        self.unit = unit
        self.street = street
        self.block = block
        self.postal = postal
        self.floor = floor
        self.building = building
    }
    
    public var addressLine1: String {
        var addressBits = [String]()
        addressBits.appendIfNotNil(self.block, string: { $0 })
        addressBits.appendIfNotNil(self.street, string: { $0 })
        return addressBits.joined(separator: " ")
    }
    
    public var addressLine2: String {
        var addressBits = [String]()
        addressBits.appendIfNotNil(self.postal, string: { $0 })
        addressBits.appendIfNotNil(self.country, string: { $0 })
        return addressBits.joined(separator: " ")
    }
    
    public var formattedAddress: String {
        var addressBits = [String]()
        addressBits.appendIfNotEmpty(self.addressLine1)
        addressBits.appendIfNotEmpty(self.addressLine2)
        return addressBits.joined(separator: "\n")
    }
}

public struct MyInfoDetails: Codable {
    private let _name: MyInfoRequiredValue
    public var name: String {
        return _name.value
    }
    
    private let _dob: MyInfoRequiredValue
    public var dob: String {
        return _dob.value
    }
    private let _email: MyInfoRequiredValue
    public var email: String {
        return _email.value
    }
    
    private let _sex: MyInfoOptionalValue?
    public var sex: String? {
        return _sex?.value
    }
    
    private let _residentialStatus: MyInfoOptionalValue?
    public var residentialStatus: String? {
        return _residentialStatus?.value
    }
    
    private let _nationality: MyInfoOptionalValue?
    public var nationality: String? {
        return _nationality?.value
    }
    
    public var address: MyInfoAddress
    public let mobileNumber: MyInfoMobileNumber?
    
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

public struct MyInfoMobileNumber: Codable {
    public let number: String?
    public let code: String?
    public let prefix: String?
    
    enum CodingKeys: String, CodingKey {
        case number = "nbr"
        case code
        case prefix
    }
    
    public var formattedNumber: String? {
        guard
            let number = self.number,
            let code = self.code,
            let prefix = self.prefix else {
                return nil
        }
        
        return [
            prefix,
            code,
            number
        ].joined()
    }
}

public struct MyInfoConfig: Codable {
    public let url: String
}
