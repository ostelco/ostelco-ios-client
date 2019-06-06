//
//  CoordinatorDestinations+Equatable.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 6/5/19.
//  Copyright © 2019 mac. All rights reserved.
//

@testable import Oya_Development_app
import ostelco_core

extension RootCoordinator.Destination: Equatable {
    
    public static func == (lhs: RootCoordinator.Destination, rhs: RootCoordinator.Destination) -> Bool {
        switch (lhs, rhs) {
        case (.login, .login),
             (.email, .email),
             (.signUp, .signUp),
             (.country, .country),
             (.home, .home):
            return true
        case (.ekyc(let lhsRegion), .ekyc(let rhsRegion)):
            return lhsRegion?.region.id == rhsRegion?.region.id
        case (.esim(let lhsProfile), .esim(let rhsProfile)):
            return lhsProfile == rhsProfile
        default:
            return false
        }
    }
}

extension CountryCoordinator.Destination: Equatable {
    
    public static func == (lhs: CountryCoordinator.Destination, rhs: CountryCoordinator.Destination) -> Bool {
        switch (lhs, rhs) {
        case (.landing, .landing),
             (.chooseCountry, .chooseCountry),
             (.allowLocation, .allowLocation),
             (.countryComplete, .countryComplete):
            return true
        case (.locationProblem(let lhsProblem), .locationProblem(let rhsProblem)):
            return lhsProblem == rhsProblem
        default:
            return false
        }
    }
}

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

extension ESimCoordinator.Destination: Equatable {
    
    public static func == (lhs: ESimCoordinator.Destination, rhs: ESimCoordinator.Destination) -> Bool {
        switch (lhs, rhs) {
        case (.setup, setup),
             (.instructions, .instructions),
             (.pendingDownload, .pendingDownload),
             (.setupComplete, .setupComplete):
            return true
        case (.success(let lhsProfile), .success(let rhsProfile)):
            return lhsProfile == rhsProfile
        default:
            return false
        }
    }
}
