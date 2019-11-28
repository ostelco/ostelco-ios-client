//
//  SimProfile.swift
//  ostelco-ios-client
//
//  Created by mac on 3/28/19.
//  Copyright © 2019 mac. All rights reserved.
//

public enum SimProfileStatus: String, Codable {
    case AVAILABLE_FOR_DOWNLOAD
    case DOWNLOADED
    case INSTALLED
    case ENABLED
    case NOT_READY
}

extension SimProfileStatus {
    func getGraphQLModel() -> PrimeGQL.SimProfileStatus {
        return PrimeGQL.SimProfileStatus(rawValue: self.rawValue)!
    }
}

public struct SimProfile: Codable, Equatable {
    public let eSimActivationCode: String
    public let alias: String
    public let iccId: String
    public let status: SimProfileStatus
    public let installedReportedByAppOn: String?
    
    public init(eSimActivationCode: String,
                alias: String,
                iccId: String,
                status: SimProfileStatus,
                installedReportedByAppOn: String?) {
        self.eSimActivationCode = eSimActivationCode
        self.alias = alias
        self.iccId = iccId
        self.status = status
        self.installedReportedByAppOn = installedReportedByAppOn
    }
    
    // Assumes that an eSimActivationCode contains three parts separated by "$" where
    // we only care about the second (esim server address) and third part (matching ID)
    // Example: LPA:1$rsp-0018.oberthur.net$LFVZH-HBCDJ-KWFBR-MGGCD
    public func hasValidESimActivationCode() -> Bool {
        return eSimActivationCode.split(separator: "$").count > 2
    }

    public var eSimServerAddress: String {
        return String(eSimActivationCode.split(separator: "$")[1])
    }
    
    public var matchingID: String {
        return String(eSimActivationCode.split(separator: "$")[2])
    }
    
    public var isDummyProfile: Bool {
        return eSimActivationCode.lowercased() == "dummy esim" || iccId.lowercased().starts(with: "test")
    }
    
    public var isInstalled: Bool {
        return status == .INSTALLED || installedReportedByAppOn != nil
    }
}

extension SimProfile {
    public init(gqlSimProfile: PrimeGQL.SimProfileFields) {
        let status = SimProfileStatus(rawValue: gqlSimProfile.status.rawValue)!
        self.init(eSimActivationCode: gqlSimProfile.eSimActivationCode,
                  alias: gqlSimProfile.alias,
                  iccId: gqlSimProfile.iccId,
                  status: status,
                  installedReportedByAppOn: gqlSimProfile.installedReportedByAppOn
        )
    }
    
    public func getGraphQLModel() -> PrimeGQL.RegionDetailsFragment.SimProfile {
        return PrimeGQL.RegionDetailsFragment.SimProfile(eSimActivationCode: eSimActivationCode, alias: alias, iccId: iccId, status: status.getGraphQLModel())
    }
}
