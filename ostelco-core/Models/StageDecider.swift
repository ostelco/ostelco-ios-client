//
//  StageDecider.swift
//  ostelco-core
//
//  Created by mac on 6/27/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

public class OnboardingContext {
    public var hasFirebaseToken: Bool
    public var hasAgreedToTerms: Bool
    public var hasSeenRegionOnboarding: Bool
    public var locationProblem: LocationProblem?
    public var hasSeenLocationPermissions: Bool
    public var hasSeenNotificationPermissions: Bool
    public var hasSeenAwesome: Bool
    public var serverIsUnreachable: Bool
    
    public init(hasFirebaseToken: Bool = false, hasAgreedToTerms: Bool = false, myInfoCode: String? = nil, hasSeenAwesome: Bool = false, serverIsUnreachable: Bool = false, locationProblem: LocationProblem? = nil, hasSeenRegionOnboarding: Bool = false, hasSeenLocationPermissions: Bool = false, hasSeenNotificationPermissions: Bool = false) {
        self.hasFirebaseToken = hasFirebaseToken
        self.hasAgreedToTerms = hasAgreedToTerms
        self.hasSeenAwesome = hasSeenAwesome
        self.serverIsUnreachable = serverIsUnreachable
        self.locationProblem = locationProblem
        self.hasSeenRegionOnboarding = hasSeenRegionOnboarding
        self.hasSeenLocationPermissions = hasSeenLocationPermissions
        self.hasSeenNotificationPermissions = hasSeenNotificationPermissions
    }
}

public class RegionOnboardingContext {
    public var hasSeenESimOnboarding: Bool
    public var hasSeenESIMInstructions: Bool
    public var selectedVerificationOption: IdentityVerificationOption?
    public var hasCameraProblem: Bool
    public var hasCompletedJumio: Bool
    public var serverIsUnreachable: Bool
    public var simProfile: SimProfile?
    
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
    
    public init(hasSeenESimOnboarding: Bool = false, hasSeenESIMInstructions: Bool = false, selectedVerificationOption: IdentityVerificationOption? = nil, hasCameraProblem: Bool = false, hasCompletedJumio: Bool = false, serverIsUnreachable: Bool = false, myInfoCode: String? = nil) {
        self.hasSeenESimOnboarding = hasSeenESimOnboarding
        self.hasSeenESIMInstructions = hasSeenESIMInstructions
        self.hasCameraProblem = hasCameraProblem
        self.selectedVerificationOption = selectedVerificationOption
        self.hasCompletedJumio = hasCompletedJumio
        self.serverIsUnreachable = serverIsUnreachable
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
        case nicknameEntry
        case locationPermissions
        case notificationPermissions
        case locationProblem(LocationProblem)
        case awesome
        case ohNo(OhNoIssueType)
    }
    
    public enum RegionStage: Equatable {
        case selectIdentityVerificationMethod([IdentityVerificationOption])
        case singpass
        case nric
        case jumio
        case address
        case pendingVerification
        case verifyMyInfo(code: String)
        case eSimOnboarding
        case eSimInstructions
        case ohNo(OhNoIssueType)
        case cameraProblem
        case done
    }
    
    public init() {}

    private func eSIMStage(_ region: RegionResponse, _ localContext: RegionOnboardingContext) -> RegionStage {
        var stages: [RegionStage] = [.eSimOnboarding, .eSimInstructions, .done]
        
        func remove(_ stage: RegionStage) {
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
        
        if let profile = region.getGraphQLModel().getSimProfile(), profile.status == .installed {
            remove(.eSimOnboarding)
            remove(.eSimInstructions)
        }
        return stages[0]
    }
    
    public func compute(context: Context?, localContext: OnboardingContext) -> Stage {
        // Error Stages
        if localContext.serverIsUnreachable {
            return .ohNo(.serverUnreachable)
        }
        
        if context?.customer != nil {
            // This is a clue the user is an existing user, don't need to show legal stuff
            return .home
        }
        
        var stages: [Stage] = [.loginCarousel, .legalStuff, .nicknameEntry, .locationPermissions, .notificationPermissions, .home]
        
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
        if let problem = localContext.locationProblem {
            return .locationProblem(problem)
        }
        
        // After you've logged in, always show notifications if they haven't seen it.
        if !localContext.hasSeenNotificationPermissions {
            return .notificationPermissions
        }
        
        return stages[0]
    }
    
    public func stageForRegion(region: RegionResponse, localContext: RegionOnboardingContext) -> RegionStage {
        // Late Stages
        if region.status == .APPROVED {
            return eSIMStage(region, localContext)
        }
        
        // Mid Stages
        var midStages: [RegionStage] = []
        func remove(_ stage: RegionStage) {
            if let index = midStages.firstIndex(of: stage) {
                midStages.remove(at: index)
            }
        }

        switch localContext.selectedVerificationOption {
        case .jumio:
            midStages.append(.cameraProblem)
            midStages.append(.jumio)
        case .none:
            let options = identityOptionsForRegionID(region.region.id)
            if options.count > 1 {
                midStages.append(.selectIdentityVerificationMethod(options))
            } else {
                midStages.append(contentsOf: [.cameraProblem, .jumio, .pendingVerification])
            }
        case .singpass:
            midStages.append(.singpass)
        case .scanIC:
            midStages.append(contentsOf: [.cameraProblem, .jumio, .address, .pendingVerification])
        }
        
        if localContext.hasCameraProblem == false {
            remove(.cameraProblem)
        }
        
        if let code = localContext.myInfoCode {
            remove(.singpass)
            midStages.append(.verifyMyInfo(code: code))
        }
        
        if localContext.hasCompletedJumio {
            remove(.jumio)
        }
        
        let kycStatusMap = region.kycStatusMap
        
        if kycStatusMap.NRIC_FIN == .APPROVED {
            remove(.nric)
        }
        
        if kycStatusMap.ADDRESS == .APPROVED {
            remove(.address)
        }
        
        if kycStatusMap.JUMIO == .APPROVED {
            remove(.pendingVerification)
            remove(.jumio)
        }
        if kycStatusMap.JUMIO == .PENDING {
            remove(.jumio)
        }
        
        if kycStatusMap.JUMIO == .REJECTED && localContext.hasCompletedJumio {
            remove(.pendingVerification)
            remove(.jumio)
            midStages.append(.ohNo(.ekycRejected))
        }
        
        return midStages[0]
    }
    
    // This is the kind of information that would be good to get from GraphQL and avoid hard-coding.
    public func identityOptionsForRegionID(_ id: String) -> [IdentityVerificationOption] {
        if id.lowercased() == "sg" {
            return [.scanIC, .singpass]
        }
        return [.jumio]
    }
}
