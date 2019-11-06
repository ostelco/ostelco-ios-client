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
    public let ADDRESS: EKYCStatus?
    
    /// Testing initializer
    public init(jumio: EKYCStatus? = nil,
                myInfo: EKYCStatus? = nil,
                nricFin: EKYCStatus? = nil,
                addressPhone: EKYCStatus? = nil) {
        self.JUMIO = jumio
        self.MY_INFO = myInfo
        self.NRIC_FIN = nricFin
        self.ADDRESS = addressPhone
    }
    
    public init(gqlKYCStatusMap: PrimeGQL.RegionDetailsFragment.KycStatusMap) {
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
        if let addressAndPhone = gqlKYCStatusMap.address?.rawValue {
            self.ADDRESS = EKYCStatus(rawValue: addressAndPhone)!
        } else {
            self.ADDRESS = nil
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
    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    public init(gqlRegion: PrimeGQL.RegionDetailsFragment.Region) {
        self.id = gqlRegion.id
        self.name = gqlRegion.name
    }
}

public struct RegionResponse: Codable {
    public let region: Region
    public let status: EKYCStatus
    public let simProfiles: [SimProfile]?
    public let kycStatusMap: KYCStatusMap
    
    /// Testing initializer
    public init(region: Region,
                status: EKYCStatus,
                simProfiles: [SimProfile]?,
                kycStatusMap: KYCStatusMap) {
        self.region = region
        self.status = status
        self.simProfiles = simProfiles
        self.kycStatusMap = kycStatusMap
    }
    
    public static func getRegionFromRegionResponseArray(_ regionResponses: [PrimeGQL.RegionDetailsFragment]) -> PrimeGQL.RegionDetailsFragment? {
        if let approvedRegion = regionResponses.first(where: { $0.status == .approved }) {
            // Hooray, at least one region has been approved!
            return approvedRegion
        }
        
        // If we've gotten here, return the last response, which is either nil or .PENDING
        return regionResponses.last
    }
    
    func getGraphQLModel() -> PrimeGQL.RegionDetailsFragment {
        return PrimeGQL.RegionDetailsFragment(
            region: PrimeGQL.RegionDetailsFragment.Region(id: region.id, name: region.name),
            status: status.toCustomerRegionStatus(),
            kycStatusMap: PrimeGQL.RegionDetailsFragment.KycStatusMap(legacyModel: kycStatusMap),
            simProfiles: simProfiles?.map({ $0.getGraphQLModel() }))
    }
}

extension PrimeGQL.RegionDetailsFragment.KycStatusMap {
    public init(legacyModel: KYCStatusMap) {
        self.init()
        if let JUMIO = legacyModel.JUMIO {
            self.jumio = JUMIO.getGraphQLModel()
        }
        if let NRIC_FIN = legacyModel.NRIC_FIN {
            self.nricFin = NRIC_FIN.getGraphQLModel()
        }
        if let ADDRESS = legacyModel.ADDRESS {
            self.address = ADDRESS.getGraphQLModel()
        }
        if let MY_INFO = legacyModel.MY_INFO {
            self.myInfo = MY_INFO.getGraphQLModel()
        }
    }
}

extension PrimeGQL.RegionDetailsFragment {
    public func getSimProfile() -> PrimeGQL.SimProfileFields? {
        return self.simProfiles?.first?.fragments.simProfileFields
    }
}

extension RegionResponse {
    public init(gqlData regionDetails: PrimeGQL.RegionDetailsFragment) {
        let region = regionDetails.region
        let status = regionDetails.status
        let kycStatusMap = regionDetails.kycStatusMap
        let simProfiles = regionDetails.simProfiles
        
        self.region = Region(gqlRegion: region)
        self.status = EKYCStatus(rawValue: status.rawValue)!
        self.kycStatusMap = KYCStatusMap(gqlKYCStatusMap: kycStatusMap)
        
        if let simProfiles = simProfiles {
            self.simProfiles = simProfiles.map({ SimProfile(gqlSimProfile: $0.fragments.simProfileFields) })
        } else {
            self.simProfiles = nil
        }
    }
}
