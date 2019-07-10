//
//  MyInfoDetails+Testing.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import ostelco_core

extension MyInfoDetails {
    
    private static var testJSONString: String {
        return """
{
    "name": {
        "lastupdated": "2018-03-20",
        "source": "1",
        "classification": "C",
        "value": "TAN XIAO HUI"
    },
    "sex": {
        "lastupdated": "2018-03-20",
        "source": "1",
        "classification": "C",
        "value": "F"
    },
    "dob": {
        "lastupdated": "2018-03-20",
        "source": "1",
        "classification": "C",
        "value": "1970-05-17"
    },
    "residentialstatus": {
        "lastupdated": "2018-03-23",
        "source": "1",
        "classification": "C",
        "value": "C"
    },
    "nationality": {
        "lastupdated": "2018-03-20",
        "source": "1",
        "classification": "C",
        "value": "SG"
    },
    "mobileno_old": {
        "lastupdated": "2018-08-23",
        "code": "65",
        "source": "4",
        "classification": "C",
        "prefix": "+",
        "nbr": "97399245"
    },
    "mobileno": {
        "lastupdated": "2019-04-05",
        "source": "2",
        "classification": "C",
        "areacode": {
            "value": "65"
        },
        "prefix": {
            "value": "+"
        },
        "nbr": {
            "value": "97399245"
        }
    },
    "email": {
        "lastupdated": "2018-08-23",
        "source": "4",
        "classification": "C",
        "value": "myinfotesting@gmail.com"
    },
    "mailadd": {
        "country": "SG",
        "unit": "128",
        "street": "BEDOK NORTH AVENUE 4",
        "lastupdated": "2018-03-20",
        "block": "102",
        "postal": "460102",
        "source": "1",
        "classification": "C",
        "floor": "09",
        "building": "PEARL GARDEN"
    },
    "mailadd_new": {
        "country": {
            "code": "SG",
            "desc": "SINGAPORE"
        },
        "unit": {
            "value": "128"
        },
        "street": {
            "value": "BEDOK NORTH AVENUE 4"
        },
        "lastupdated": "2019-04-05",
        "block": {
            "value": "102"
        },
        "source": "1",
        "postal": {
            "value": "460102"
        },
        "classification": "C",
        "floor": {
            "value": "09"
        },
        "type": "SG",
        "building": {
            "value": "PEARL GARDEN"
        }
    }
}
"""
    }
    
    static var testInfo: MyInfoDetails? {
        guard let json = self.testJSONString.data(using: .utf8) else {
            return nil
        }
        
        do {
            let myInfo = try JSONDecoder().decode(MyInfoDetails.self, from: json)
            print("MyInfo \(myInfo)")
            print("Address 1 \(myInfo.address.addressLine1)")
            print("Address 2 \(myInfo.address.addressLine2)")
            return myInfo
        } catch {
            print("Error \(error)")
            return nil
        }
    }
}
