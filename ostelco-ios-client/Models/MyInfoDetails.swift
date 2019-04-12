//
//  MyInfoDetails.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 11/04/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import SwiftyJSON

struct MyInfoAddress{
    let country: String?
    let unit: String?
    let street: String?
    let block: String?
    let postal: String?
    let floor: String?
    let building: String?

    static func fromJSON(_ json: JSON) -> MyInfoAddress {
        return MyInfoAddress(
            country: json["country"].string,
            unit: json["unit"].string,
            street: json["street"].string,
            block: json["block"].string,
            postal: json["postal"].string,
            floor: json["floor"].string,
            building: json["building"].string
        )
    }
    func getAddressLine1() -> String {
        var addressLine1: String = ""
        if let block = block {
            addressLine1 = "\(block) "
        }
        if let street = street {
            addressLine1 += "\(street) "
        }
        return addressLine1
    }
    func getAddressLine2() -> String {
        var addressLine2: String = ""
        if let postal = postal {
            addressLine2 = "\(postal) "
        }
        if let country = country {
            addressLine2 += "\(country) "
        }
        return addressLine2
    }
}

struct MyInfoDetails {
    let name: String
    let dob: String
    let email: String
    let address: MyInfoAddress
    let sex: String?
    let residentialStatus: String?
    let nationality: String?
    let mobileNumber: String?

    static func fromJSON(_ json: JSON) -> MyInfoDetails? {
        let address = MyInfoAddress.fromJSON(json["regadd"])
        let mobileno = mobileNumberFromJSON(json["mobileno"])
        let nationality = json["nationality"]["value"].string
        let residentialstatus = json["residentialstatus"]["value"].string
        let sex = json["sex"]["value"].string
        if let name = json["name"]["value"].string,
            let email = json["email"]["value"].string,
            let dob = json["dob"]["value"].string {
            return MyInfoDetails(
                name: name,
                dob: dob,
                email: email,
                address: address,
                sex:sex,
                residentialStatus: residentialstatus,
                nationality: nationality,
                mobileNumber: mobileno
            )
        }
        return nil
    }
    static func mobileNumberFromJSON(_ json: JSON) -> String? {
        if let number = json["nbr"].string,
            let code = json["code"].string,
            let prefix = json["prefix"].string {
            return "\(prefix)\(code)\(number)"
        }
        return nil
    }

}
