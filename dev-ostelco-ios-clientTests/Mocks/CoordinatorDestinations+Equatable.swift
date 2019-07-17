//
//  CoordinatorDestinations+Equatable.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 6/5/19.
//  Copyright © 2019 mac. All rights reserved.
//

@testable import Oya_Development_app
import ostelco_core
/*
extension DefaultEKYCCoordinator.Destination: Equatable {
    public static func == (lhs: DefaultEKYCCoordinator.Destination, rhs: DefaultEKYCCoordinator.Destination) -> Bool {
        switch (lhs, rhs) {
        case (.goBackAndChooseCountry, .goBackAndChooseCountry),
             (.landing, .landing),
             (.jumio, .jumio),
             (.ekycRejected, .ekycRejected),
             (.waitingForVerification, .waitingForVerification):
            return true
        case (.success(let lhsRegion), .success(let rhsRegion)):
            return lhsRegion.region.id == rhsRegion.region.id
        default:
            return false
        }
    }
}

extension SingaporeEKYCCoordinator.Destination: Equatable {
    
    public static func == (lhs: SingaporeEKYCCoordinator.Destination, rhs: SingaporeEKYCCoordinator.Destination) -> Bool {
        switch (lhs, rhs) {
        case (.goBackAndChooseCountry, .goBackAndChooseCountry),
             (.landing, .landing),
             (.selectVerificationMethod, .selectVerificationMethod),
             (.jumio, .jumio),
             (.singPass, .singPass),
             (.enterAddress, .enterAddress),
             (.verifySingPassAddress, .verifySingPassAddress),
             (.stepsForNRIC, .stepsForNRIC),
             (.enterNRIC, .enterNRIC),
             (.ekycRejected, .ekycRejected),
             (.waitingForVerification, .waitingForVerification):
            return true
        case (.editSingPassAddress(let lhsAddress, let lhsDelegate), .editSingPassAddress(let rhsAddress, let rhsDelegate)):
            return lhsAddress?.formattedAddress == rhsAddress?.formattedAddress &&
                lhsDelegate === rhsDelegate
        case (.success(let lhsRegion), .success(let rhsRegion)):
            return lhsRegion.region.id == rhsRegion.region.id
        default:
            return false
        }
    }
}
*/
