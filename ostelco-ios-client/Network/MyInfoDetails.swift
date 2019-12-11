//
//  MyInfoDetails.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 11/04/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

public struct MyInfoAddress: Codable {
    private let _unit: MyInfoOptionalValue?
    public var unit: String? {
        return _unit?.value
    }
    private let _street: MyInfoOptionalValue?
    public var street: String? {
        return _street?.value
    }
    private let _block: MyInfoOptionalValue?
    public var block: String? {
        return _block?.value
    }
    private let _postal: MyInfoOptionalValue?
    public var postal: String? {
        return _postal?.value
    }
    private let _floor: MyInfoOptionalValue?
    public var floor: String? {
        return _floor?.value
    }
    private let _building: MyInfoOptionalValue?
    public var building: String? {
        return _building?.value
    }

    enum CodingKeys: String, CodingKey {
        case _unit = "unit"
        case _street = "street"
        case _block = "block"
        case _postal = "postal"
        case _floor = "floor"
        case _building = "building"
    }

    public init(floor: String?,
                unit: String?,
                block: String?,
                building: String?,
                street: String?,
                postal: String?
    ) {
        self._floor = MyInfoOptionalValue(value: floor)
        self._unit = MyInfoOptionalValue(value: unit)
        self._block = MyInfoOptionalValue(value: block)
        self._building = MyInfoOptionalValue(value: building)
        self._street = MyInfoOptionalValue(value: street)
        self._postal = MyInfoOptionalValue(value: postal)
    }
    
    public var floorAndUnit: String {
        var addressBits = [String]()
        
        if let unit = self.unit, unit.isNotEmpty {
            addressBits.append("#\(unit)")
        }
        if let floor = self.floor, floor.isNotEmpty {
            addressBits.append(floor)
        }
        return addressBits.joined(separator: "-")
    }
    
    public var blockAndBuilding: String {
        var addressBits = [String]()
        addressBits.appendIfNotNil(self.block, string: { $0 })
        addressBits.appendIfNotNil(self.building, string: { $0 })
        return addressBits.joined(separator: " ")
    }
    
    public var addressLine1: String {
        var addressBits = [String]()
        addressBits.appendIfNotEmpty(self.floorAndUnit)
        addressBits.appendIfNotEmpty(self.blockAndBuilding)
        return addressBits.joined(separator: ", ")
    }
    
    public var addressLine2: String {
        var addressBits = [String]()
        
        addressBits.appendIfNotNil(self.street, string: { $0 })
        addressBits.appendIfNotNil(self.postal, string: { $0 })
        return addressBits.joined(separator: ", ")
    }
    
    public var formattedAddress: String {
        var addressBits = [String]()
        addressBits.appendIfNotEmpty(self.addressLine1)
        addressBits.appendIfNotEmpty(self.addressLine2)
        return addressBits.joined(separator: "\n")
    }
    
    public var isEmpty: Bool {
        return formattedAddress.isEmpty
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
    
    private var _mailadd: MyInfoAddress
    private var _regadd: MyInfoAddress
    
    private let _passexpirydate: MyInfoRequiredValue
    public var passExpiryDate: String {
        return _passexpirydate.value
    }
    
    private let _uinfin: MyInfoRequiredValue
    public var uinfin: String {
        return _uinfin.value
    }
    
    public var address: MyInfoAddress {
        get {
            if !_regadd.isEmpty {
                return _regadd
            } else {
                return _mailadd
            }
        }
        set {
            _regadd = newValue
        }
    }
            
    enum CodingKeys: String, CodingKey {
        case _name = "name"
        case _dob = "dob"
        case _mailadd = "mailadd"
        case _regadd = "regadd"
        case _passexpirydate = "passexpirydate"
        case _uinfin = "uinfin"
    }
}

struct MyInfoRequiredValue: Codable {
    let value: String
}

struct MyInfoOptionalValue: Codable {
    let value: String?
}

struct MyInfoOptionalCode: Codable {
    let code: String?
    let description: String?
    enum CodingKeys: String, CodingKey {
        case code
        case description = "desc"
    }
}

public struct MyInfoMobileNumber: Codable {
    private let _number: MyInfoOptionalValue?
    public var number: String? {
        return _number?.value
    }
    private let _code: MyInfoOptionalValue?
    public var code: String? {
        return _code?.value
    }
    private let _prefix: MyInfoOptionalValue?
    public var prefix: String? {
        return _prefix?.value
    }

    enum CodingKeys: String, CodingKey {
        case _number = "nbr"
        case _code = "areacode"
        case _prefix = "prefix"
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
