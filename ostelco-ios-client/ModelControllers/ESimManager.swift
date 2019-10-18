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
    static let shared = ESimManager()
    
    /**
     Tries to download and install an eSIM on the device using apples eSIM APIs.
     */
    func addPlan(address: String, matchingID: String, iccid: String) -> PromiseKit.Promise<Void> {
        let planObj = CTCellularPlanProvisioning()
        
        let request = CTCellularPlanProvisioningRequest()
        request.address = address
        request.matchingID = matchingID
        request.iccid = iccid

        return PromiseKit.Promise<Void> { seal in
            planObj.addPlan(with: request) { (result: CTCellularPlanProvisioningAddPlanResult) in
                switch result {
                case .unknown:
                    seal.reject(ApplicationErrors.General.addPlanFailed(message: "Unknown"))
                case .fail:
                    seal.reject(ApplicationErrors.General.addPlanFailed(message: "Failed"))
                case .success:
                    AppEvents.logEvent(.completedRegistration)
                    seal.fulfill(())
                @unknown default:
                    seal.reject(ApplicationErrors.General.addPlanFailed(message: "Unknown default"))
                }
            }
        }
    }
}
