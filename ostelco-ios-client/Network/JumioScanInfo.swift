//
//  JumioScanInfo.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 5/31/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

///https://github.com/Jumio/implementation-guides/blob/master/netverify/callback.md
public enum JumioVerificationStatus: String, Codable {
    case APPROVED_VERIFIED
    case DENIED_FRAUD
    case DENIED_UNSUPPORTED_ID_TYPE
    case DENIED_UNSUPPORTED_ID_COUNTRY
    case ERROR_NOT_READABLE_ID
    case NO_ID_UPLOADED
}

/// https://github.com/Jumio/implementation-guides/blob/master/netverify/callback.md#reject-reason
public struct JumioRejectionReason: Codable {
    public enum Description: String, Codable {
        case MANIPULATED_DOCUMENT
        case PHOTOCOPY_BLACK_WHITE
        case PHOTOCOPY_COLOR
        case DIGITAL_COPY
        case FRAUDSTER
        case FAKE
        case PHOTO_MISMATCH
        case MRZ_CHECK_FAILED
        case PUNCHED_DOCUMENT
        case CHIP_DATA_MANIPULATED
        case MISMATCH_PRINTED_BARCODE_DATA
        case NOT_READABLE_DOCUMENT
        case NO_DOCUMENT
        case SAMPLE_DOCUMENT
        case MISSING_BACK
        case WRONG_DOCUMENT_PAGE
        case MISSING_SIGNATURE
        case CAMERA_BLACK_WHITE
        case DIFFERENT_PERSONS_SHOWN
        case MANUAL_REJECTION
        
        public init?(code: String) {
            guard let intCode = Int(code) else {
                return nil
            }
            
            switch intCode {
            case 100:
                self = .MANIPULATED_DOCUMENT
            case 102:
                self = .PHOTOCOPY_BLACK_WHITE
            case 103:
                self = .PHOTOCOPY_COLOR
            case 104:
                self = .DIGITAL_COPY
            case 105:
                self = .FRAUDSTER
            case 106:
                self = .FAKE
            case 107:
                self = .PHOTO_MISMATCH
            case 108:
                self = .MRZ_CHECK_FAILED
            case 109:
                self = .PUNCHED_DOCUMENT
            case 110:
                self = .CHIP_DATA_MANIPULATED
            case 111:
                self = .MISMATCH_PRINTED_BARCODE_DATA
            case 200:
                self = .NOT_READABLE_DOCUMENT
            case 201:
                self = .NO_DOCUMENT
            case 206:
                self = .MISSING_BACK
            case 207:
                self = .WRONG_DOCUMENT_PAGE
            case 209:
                self = .MISSING_SIGNATURE
            case 210:
                self = .CAMERA_BLACK_WHITE
            case 211:
                self = .DIFFERENT_PERSONS_SHOWN
            case 300:
                self = .MANUAL_REJECTION
            default:
                return nil
            }
        }
    }
    
    public let code: String?
    public let description: JumioRejectionReason.Description?
    public let details: JumioRejectionReasonDetails?
    
    public enum CodingKeys: String, CodingKey {
        case code = "rejectReasonCode"
        case description = "rejectReasonDescription"
        case details = "rejectReasonDetails"
    }
}

/// https://github.com/Jumio/implementation-guides/blob/master/netverify/callback.md#reject-reason-details
public struct JumioRejectionReasonDetails: Codable {
    public enum Description: String, Codable {
        case PHOTO
        case DOCUMENT_NUMBER
        case EXPIRY
        case DOB
        case NAME
        case ADDRESS
        case SECURITY_CHECKS
        case SIGNATURE
        case PERSONAL_NUMBER
        case PLACE_OF_BIRTH
        case BLURRED
        case BAD_QUALITY
        case MISSING_PART_DOCUMENT
        case HIDDEN_PART_DOCUMENT
        case DAMAGED_DOCUMENT
        
        public init?(code: String) {
            guard let intCode = Int(code) else {
                return nil
            }
            
            switch intCode {
            case 1001:
                self = .PHOTO
            case 1002:
                self = .DOCUMENT_NUMBER
            case 1003:
                self = .EXPIRY
            case 1004:
                self = .DOB
            case 1005:
                self = .NAME
            case 1006:
                self = .ADDRESS
            case 1007:
                self = .SECURITY_CHECKS
            case 1008:
                self = .SIGNATURE
            case 1009:
                self = .PERSONAL_NUMBER
            case 10011:
                self = .PLACE_OF_BIRTH
            case 2001:
                self = .BLURRED
            case 2002:
                self = .BAD_QUALITY
            case 2003:
                self = .MISSING_PART_DOCUMENT
            case 2004:
                self = .HIDDEN_PART_DOCUMENT
            case 2005:
                self = .DAMAGED_DOCUMENT
            default:
                return nil
            }
        }
    }
    
    public let code: String?
    public let description: JumioRejectionReasonDetails.Description?
    
    public enum CodingKeys: String, CodingKey {
        case code = "detailsCode"
        case description = "detailsDescription"
    }
}
