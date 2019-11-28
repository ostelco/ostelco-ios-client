//
//  ESimManager.swift
//  ostelco-ios-client
//
//  Created by mac on 9/27/19.
//  Copyright © 2019 mac. All rights reserved.
//

import CoreTelephony
import PromiseKit
import ostelco_core
import FacebookCore

class ESimManager {
    /**
     Tries to download and install an eSIM on the device using apples eSIM APIs.
     */
    func addPlan(address: String, matchingID: String, simProfile: SimProfile) -> PromiseKit.Promise<SimProfile> {
        let planObj = CTCellularPlanProvisioning()
        
        let request = CTCellularPlanProvisioningRequest()
        request.address = address
        request.matchingID = matchingID
        request.iccid = simProfile.iccId

        return PromiseKit.Promise<SimProfile> { seal in
            planObj.addPlan(with: request) { (result: CTCellularPlanProvisioningAddPlanResult) in
                switch result {
                case .unknown:
                    seal.reject(ApplicationErrors.General.addPlanFailed(message: "Unknown"))
                case .fail:
                    seal.reject(ApplicationErrors.General.addPlanFailed(message: "Failed"))
                case .success:
                    AppEvents.logEvent(.completedRegistration)
                    seal.fulfill(simProfile)
                @unknown default:
                    seal.reject(ApplicationErrors.General.addPlanFailed(message: "Unknown default"))
                }
            }
        }
    }
}
