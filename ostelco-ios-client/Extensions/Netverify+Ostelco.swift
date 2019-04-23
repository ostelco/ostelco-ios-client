//
//  Netverify+Ostelco.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/17/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import Netverify

extension NetverifyDocumentType {
    
    var ostelcoDocumentType: String {
        switch self {
        case .driverLicense:
            return "DL"
        case .identityCard:
            return "ID"
        case .passport:
            return "PP"
        case .visa:
            return "Visa"
        default:
            return ""
        }
    }
}

extension NetverifyGender {
    
    var ostelcoGender: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .F:
            return "female"
        case .M:
            return "male"
        case .X:
            return "Unspecified"
        default:
            return "Unknown"
        }
    }
}

extension NetverifyDocumentData {
    
    func toOstelcoString() -> String {
        let documentType = self.selectedDocumentType.ostelcoDocumentType
        let gender = self.gender.ostelcoGender
        
        var messages = [String]()
        messages.append("Selected Country: \(self.selectedCountry)")
        messages.append("Document Type: \(documentType)")
        messages.appendIfNotNil(self.idNumber, string: { "ID Number: \($0)" })
        messages.appendIfNotNil(self.personalNumber, string: { "Personal Number: \($0)" })
        messages.appendIfNotNil(self.issuingDate, string: { "Issuing Date: \($0)" })
        messages.appendIfNotNil(self.expiryDate, string: { "Expiry Date: \($0)" })
        messages.appendIfNotNil(self.issuingCountry, string: { "Issuing Country: \($0)" })
        messages.appendIfNotNil(self.optionalData1, string: { "Optional Data 1: \($0)" })
        messages.appendIfNotNil(self.optionalData2, string: { "Optional Data 2: \($0)" })
        messages.appendIfNotNil(self.lastName, string: { "Last Name: \($0)" })
        messages.appendIfNotNil(self.firstName, string: { "First Name: \($0)"})
        messages.appendIfNotNil(self.dob, string: { "dob: \($0)" })
        messages.append("Gender: \(gender)")
        messages.appendIfNotNil(self.originatingCountry, string: { "Originating Country: \($0)" })
        messages.appendIfNotNil(self.addressLine, string: { "Street: \($0)" })
        messages.appendIfNotNil(self.city, string: { "City: \($0)" })
        messages.appendIfNotNil(self.subdivision, string: { "State: \($0)" })
        messages.appendIfNotNil(self.postCode, string: { "Postal Code: \($0)" })
        
        // Raw MRZ data
        if let mrz = self.mrzData {
            messages.append("MRZ Data:")
            messages.appendIfNotNil(mrz.line1, string: { "\($0)" })
            messages.appendIfNotNil(mrz.line2, string: { "\($0)" })
            messages.appendIfNotNil(mrz.line3, string: { "\($0)" })
        }
        return messages.joined(separator: "\n")
    }
}
