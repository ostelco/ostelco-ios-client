//
//  Region.swift
//  ostelco-ios-client
//
//  Created by mac on 3/28/19.
//  Copyright © 2019 mac. All rights reserved.
//

public struct KYCStatusMap: Codable {
    public let JUMIO: EKYCStatus?
    public let MY_INFO: EKYCStatus?
    public let NRIC_FIN: EKYCStatus?
    public let ADDRESS_AND_PHONE_NUMBER: EKYCStatus?
    
    /// Testing initializer
    public init(jumio: EKYCStatus? = nil,
                myInfo: EKYCStatus? = nil,
                nricFin: EKYCStatus? = nil,
                addressPhone: EKYCStatus? = nil) {
        self.JUMIO = jumio
        self.MY_INFO = myInfo
        self.NRIC_FIN = nricFin
        self.ADDRESS_AND_PHONE_NUMBER = addressPhone
    }
    
    public init(gqlKYCStatusMap: RegionDetailsFragment.KycStatusMap) {
        if let jumio = gqlKYCStatusMap.jumio?.rawValue {
            self.JUMIO = EKYCStatus(rawValue: jumio)!
        } else {
            self.JUMIO = nil
        }
        if let myInfo = gqlKYCStatusMap.myInfo?.rawValue {
            self.MY_INFO = EKYCStatus(rawValue: myInfo)!
        } else {
            self.MY_INFO = nil
        }
        if let addressAndPhone = gqlKYCStatusMap.addressAndPhoneNumber?.rawValue {
            self.ADDRESS_AND_PHONE_NUMBER = EKYCStatus(rawValue: addressAndPhone)!
        } else {
            self.ADDRESS_AND_PHONE_NUMBER = nil
        }
        if let nricFin = gqlKYCStatusMap.nricFin?.rawValue {
            self.NRIC_FIN = EKYCStatus(rawValue: nricFin)!
        } else {
            self.NRIC_FIN = nil
        }
    }
}

public struct Region: Codable {
    public let id: String
    public let name: String
    
    /// Testing initializer
    public init(id: String,
                name: String) {
        self.id = id
        self.name = name
    }
    
    // Convenience method to access the related country object.
    public var country: Country {
        return Country(self.id)
    }
    
    public init(gqlRegion: RegionDetailsFragment.Region) {
        self.id = gqlRegion.id
        self.name = gqlRegion.name
    }
}

public struct RegionResponse: Codable {
    public let region: Region
    public let status: EKYCStatus
    public let simProfiles: [SimProfileLegacy]?
    public let kycStatusMap: KYCStatusMap
    
    /// Testing initializer
    public init(region: Region,
                status: EKYCStatus,
                simProfiles: [SimProfileLegacy]?,
                kycStatusMap: KYCStatusMap) {
        self.region = region
        self.status = status
        self.simProfiles = simProfiles
        self.kycStatusMap = kycStatusMap
    }
    
    public static func getRegionFromRegionResponseArray(_ regionResponses: [RegionDetailsFragment]) -> RegionDetailsFragment? {
        if let approvedRegion = regionResponses.first(where: { $0.status == .approved }) {
            // Hooray, at least one region has been approved!
            return approvedRegion
        }
        
        // If we've gotten here, return the last response, which is either nil or .PENDING
        return regionResponses.last
    }
    
    func getGraphQLModel() -> RegionDetailsFragment {
        return RegionDetailsFragment(
            region: RegionDetailsFragment.Region(id: region.id, name: region.name),
            status: status.toCustomerRegionStatus(),
            kycStatusMap: RegionDetailsFragment.KycStatusMap(legacyModel: kycStatusMap),
            simProfiles: simProfiles?.map({ $0.getGraphQLModel() }))
    }
}

extension RegionDetailsFragment.KycStatusMap {
    public init(legacyModel: KYCStatusMap) {
        self.init()
        if let JUMIO = legacyModel.JUMIO {
            self.jumio = JUMIO.getGraphQLModel()
        }
        if let NRIC_FIN = legacyModel.NRIC_FIN {
            self.nricFin = NRIC_FIN.getGraphQLModel()
        }
        if let ADDRESS_AND_PHONE_NUMBER = legacyModel.ADDRESS_AND_PHONE_NUMBER {
            self.addressAndPhoneNumber = ADDRESS_AND_PHONE_NUMBER.getGraphQLModel()
        }
        if let MY_INFO = legacyModel.MY_INFO {
            self.myInfo = MY_INFO.getGraphQLModel()
        }
    }
}

extension RegionDetailsFragment {
    public func getSimProfile() -> SimProfileFields? {
        return self.simProfiles?.first?.fragments.simProfileFields
    }
}

extension RegionResponse {
    public init(gqlData regionDetails: RegionDetailsFragment) {
        let region = regionDetails.region
        let status = regionDetails.status
        let kycStatusMap = regionDetails.kycStatusMap
        let simProfiles = regionDetails.simProfiles
        
        self.region = Region(gqlRegion: region)
        self.status = EKYCStatus(rawValue: status.rawValue)!
        self.kycStatusMap = KYCStatusMap(gqlKYCStatusMap: kycStatusMap)
        
        if let simProfiles = simProfiles {
            self.simProfiles = simProfiles.map({ SimProfileLegacy(gqlSimProfile: $0.fragments.simProfileFields) })
        } else {
            self.simProfiles = nil
        }
    }
}
