//
//  StageDecider.swift
//  ostelco-core
//
//  Created by mac on 6/27/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

public class LocalContext {
    public var hasFirebaseToken: Bool
    public var hasAgreedToTerms: Bool
    public var hasSeenNotificationPermissions: Bool
    public var hasSeenRegionOnboarding: Bool
    public var selectedRegion: Region?
    public var regionVerified: Bool
    public var locationProblem: LocationProblem?
    public var hasSeenVerifyIdentifyOnboarding: Bool
    public var selectedVerificationOption: IdentityVerificationOption?
    public var hasSeenLocationPermissions: Bool
    
    private var _myInfoCode: String?
    public var myInfoCode: String? {
        get {
            let code = _myInfoCode
            _myInfoCode = nil
            return code
        }
        set(value) {
            _myInfoCode = value
        }
    }
    public var hasSeenESimOnboarding: Bool
    public var hasSeenESIMInstructions: Bool
    public var hasSeenAwesome: Bool
    public var hasCompletedJumio: Bool // Needs to be persisted
    public var hasCompletedAddress: Bool
    public var serverIsUnreachable: Bool
    
    public init(selectedRegion: Region? = nil, hasFirebaseToken: Bool = false, hasAgreedToTerms: Bool = false, hasSeenNotificationPermissions: Bool = false, regionVerified: Bool = false, hasSeenVerifyIdentifyOnboarding: Bool = false, selectedVerificationOption: IdentityVerificationOption? = nil, myInfoCode: String? = nil, hasSeenESimOnboarding: Bool = false, hasSeenESIMInstructions: Bool = false, hasSeenAwesome: Bool = false, hasCompletedJumio: Bool = false, hasCompletedAddress: Bool = false, serverIsUnreachable: Bool = false, locationProblem: LocationProblem? = nil, hasSeenRegionOnboarding: Bool = false, hasSeenLocationPermissions: Bool = false) {
        self.selectedRegion = selectedRegion
        self.hasFirebaseToken = hasFirebaseToken
        self.hasAgreedToTerms = hasAgreedToTerms
        self.hasSeenNotificationPermissions = hasSeenNotificationPermissions
        self.regionVerified = regionVerified
        self.hasSeenVerifyIdentifyOnboarding = hasSeenVerifyIdentifyOnboarding
        self.selectedVerificationOption = selectedVerificationOption
        self.hasSeenESimOnboarding = hasSeenESimOnboarding
        self.hasSeenESIMInstructions = hasSeenESIMInstructions
        self.hasSeenAwesome = hasSeenAwesome
        self.hasCompletedJumio = hasCompletedJumio
        self.hasCompletedAddress = hasCompletedAddress
        self.serverIsUnreachable = serverIsUnreachable
        self.locationProblem = locationProblem
        self.hasSeenRegionOnboarding = hasSeenRegionOnboarding
        self.hasSeenLocationPermissions = hasSeenLocationPermissions
        self.myInfoCode = myInfoCode
    }
}

public enum IdentityVerificationOption {
    case singpass
    case scanIC
    case jumio
}

public struct StageDecider {
    public enum Stage: Equatable {
        case home
        case loginCarousel
        case legalStuff
        case notificationPermissions
        case nicknameEntry
        case regionOnboarding
        case selectRegion
        case locationPermissions
        case verifyIdentityOnboarding
        case selectIdentityVerificationMethod([IdentityVerificationOption])
        case singpass
        case nric
        case jumio
        case address
        case pendingVerification
        case verifyMyInfo(code: String)
        case eSimOnboarding
        case eSimInstructions
        case pendingESIMInstall
        case awesome
        case ohNo(OhNoIssueType)
        case locationProblem(LocationProblem)
    }
    
    public init() {}
    
    private func preLoggedInStage(_ localContext: LocalContext) -> Stage {
        var stages: [Stage] = [.loginCarousel, .legalStuff, .locationPermissions, .nicknameEntry]
        
        func remove(_ stage: Stage) {
            if let index = stages.firstIndex(of: stage) {
                stages.remove(at: index)
            }
        }
        
        if localContext.hasFirebaseToken {
            remove(.loginCarousel)
        }
        if localContext.hasAgreedToTerms {
            remove(.legalStuff)
        }
        if localContext.hasSeenLocationPermissions {
            remove(.locationPermissions)
        }
        return stages[0]
    }

    private func eSIMStage(_ region: PrimeGQL.RegionDetailsFragment, _ localContext: LocalContext) -> Stage {
        var stages: [Stage] = [.eSimOnboarding, .eSimInstructions, .pendingESIMInstall, .awesome, .home]
        
        func remove(_ stage: Stage) {
            if let index = stages.firstIndex(of: stage) {
                stages.remove(at: index)
            }
        }
        
        if localContext.hasSeenESimOnboarding {
            remove(.eSimOnboarding)
        }
        
        if localContext.hasSeenESIMInstructions {
            remove(.eSimInstructions)
        }
        
        if let profile = region.getSimProfile(), profile.status == .installed {
            remove(.eSimOnboarding)
            remove(.eSimInstructions)
            remove(.pendingESIMInstall)
            
            if !localContext.hasSeenESimOnboarding {
                remove(.awesome)
            }
        }
        
        if localContext.hasSeenAwesome {
            remove(.awesome)
        }
        return stages[0]
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    public func compute(context: Context?, localContext: LocalContext) -> Stage {
        
        // Error Stages
        if localContext.serverIsUnreachable {
            return .ohNo(.serverUnreachable)
        }
        
        if let problem = localContext.locationProblem {
            return .locationProblem(problem)
        }
        
        // Initial Stages
        guard let context = context else {
            return preLoggedInStage(localContext)
        }
        
        // After you've logged in, always show notifications if they haven't seen it.
        if !localContext.hasSeenNotificationPermissions {
            return .notificationPermissions
        }
        
        // Late Stages
        if let region = context.getRegion(), region.status == .approved {
            return eSIMStage(region, localContext)
        }
        
        // Mid Stages
        var midStages: [Stage] = [.regionOnboarding, .selectRegion, .verifyIdentityOnboarding]
        func remove(_ stage: StageDecider.Stage) {
            if let index = midStages.firstIndex(of: stage) {
                midStages.remove(at: index)
            }
        }
        
        if localContext.hasSeenRegionOnboarding || localContext.regionVerified {
            remove(.regionOnboarding)
        }
        if localContext.selectedRegion != nil {
            remove(.selectRegion)
        }
        if context.getRegion() != nil {
            remove(.regionOnboarding)
            remove(.selectRegion)
        }
        if localContext.hasSeenVerifyIdentifyOnboarding {
            remove(.verifyIdentityOnboarding)
        }
        
        switch localContext.selectedVerificationOption {
        case .jumio:
            midStages.append(.jumio)
        case .none:
            if let region = localContext.selectedRegion {
                let options = identityOptionsForRegion(region)
                if options.count > 1 {
                    midStages.append(.selectIdentityVerificationMethod(options))
                } else {
                    midStages.append(contentsOf: [.jumio, .pendingVerification])
                }
            }
        case .singpass:
            midStages.append(.singpass)
        case .scanIC:
            midStages.append(contentsOf: [.nric, .jumio, .address, .pendingVerification])
        }
        
        if let code = localContext.myInfoCode {
            remove(.singpass)
            midStages.append(.verifyMyInfo(code: code))
        }
        
        if localContext.hasCompletedJumio {
            remove(.jumio)
        }
        
        if let kycStatusMap = context.getRegion()?.kycStatusMap {
            if kycStatusMap.nricFin == .approved {
                remove(.nric)
            }
            if kycStatusMap.jumio == .approved {
                remove(.jumio)
            }
            if kycStatusMap.addressAndPhoneNumber == .approved {
                remove(.address)
            }
            if kycStatusMap.jumio == .rejected {
                remove(.pendingVerification)
                midStages.append(.ohNo(.ekycRejected))
            }
        }
        
        return midStages[0]
    }
    
    // This is the kind of information that would be good to get from GraphQL and avoid hard-coding.
    private func identityOptionsForRegion(_ region: Region) -> [IdentityVerificationOption] {
        if region.id.lowercased() == "sg" {
            return [.scanIC, .singpass]
        }
        return [.jumio]
    }
}
