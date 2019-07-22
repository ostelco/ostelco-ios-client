//
//  StageDecider.swift
//  ostelco-core
//
//  Created by mac on 6/27/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

public struct LocalContext {
    public var hasSeenLoginCarousel: Bool
    public var enteredEmailAddress: String?
    public var hasFirebaseToken: Bool
    public var hasAgreedToTerms: Bool
    public var hasSeenNotificationPermissions: Bool
    public var hasSeenRegionOnboarding: Bool
    public var selectedRegion: Region?
    public var regionVerified: Bool
    public var locationProblem: LocationProblem?
    public var hasSeenVerifyIdentifyOnboarding: Bool
    public var selectedVerificationOption: IdentityVerificationOption?
    public var myInfoCode: String? // Needs to be persisted
    public var hasSeenESimOnboarding: Bool
    public var hasSeenESIMInstructions: Bool
    public var hasSeenAwesome: Bool
    public var hasCompletedJumio: Bool // Needs to be persisted
    public var hasCompletedAddress: Bool
    public var serverIsUnreachable: Bool
    
    public init(selectedRegion: Region? = nil, hasSeenLoginCarousel: Bool = false, enteredEmailAddress: String? = nil, hasFirebaseToken: Bool = false, hasAgreedToTerms: Bool = false, hasSeenNotificationPermissions: Bool = false, regionVerified: Bool = false, hasSeenVerifyIdentifyOnboarding: Bool = false, selectedVerificationOption: IdentityVerificationOption? = nil, myInfoCode: String? = nil, hasSeenESimOnboarding: Bool = false, hasSeenESIMInstructions: Bool = false, hasSeenAwesome: Bool = false, hasCompletedJumio: Bool = false, hasCompletedAddress: Bool = false, serverIsUnreachable: Bool = false, locationProblem: LocationProblem? = nil, hasSeenRegionOnboarding: Bool = false) {
        self.selectedRegion = selectedRegion
        self.hasSeenLoginCarousel = hasSeenLoginCarousel
        self.enteredEmailAddress = enteredEmailAddress
        self.hasFirebaseToken = hasFirebaseToken
        self.hasAgreedToTerms = hasAgreedToTerms
        self.hasSeenNotificationPermissions = hasSeenNotificationPermissions
        self.regionVerified = regionVerified
        self.hasSeenVerifyIdentifyOnboarding = hasSeenVerifyIdentifyOnboarding
        self.selectedVerificationOption = selectedVerificationOption
        self.myInfoCode = myInfoCode
        self.hasSeenESimOnboarding = hasSeenESimOnboarding
        self.hasSeenESIMInstructions = hasSeenESIMInstructions
        self.hasSeenAwesome = hasSeenAwesome
        self.hasCompletedJumio = hasCompletedJumio
        self.hasCompletedAddress = hasCompletedAddress
        self.serverIsUnreachable = serverIsUnreachable
        self.locationProblem = locationProblem
        self.hasSeenRegionOnboarding = hasSeenRegionOnboarding
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
        case emailEntry
        case checkYourEmail(email: String)
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
    
    private func preLoggedInStage(_ localContext: LocalContext) -> StageDecider.Stage {
        if localContext.hasFirebaseToken {
            if localContext.hasAgreedToTerms {
                return .nicknameEntry
            }
            return .legalStuff
        } else {
            // This is the cold-start shortcut.
            if let email = localContext.enteredEmailAddress, !localContext.hasSeenLoginCarousel {
                return .checkYourEmail(email: email)
            }
            
            if localContext.hasSeenLoginCarousel {
                if let emailAddress = localContext.enteredEmailAddress {
                    return .checkYourEmail(email: emailAddress)
                }
                return .emailEntry
            }
            return .loginCarousel
        }
    }

    private func eSIMStage(_ region: RegionResponse, _ localContext: LocalContext) -> StageDecider.Stage {
        if let profile = region.getSimProfile() {
            if profile.status == .INSTALLED {
                if localContext.hasSeenAwesome || !localContext.hasSeenESimOnboarding {
                    return .home
                }
                return .awesome
            }
        }
        
        if localContext.hasSeenESimOnboarding {
            if localContext.hasSeenESIMInstructions {
                return .pendingESIMInstall
            }
            return .eSimInstructions
        }
        return .eSimOnboarding
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    public func compute(context: Context?, localContext: LocalContext) -> Stage {
        
        if localContext.serverIsUnreachable {
            return .ohNo(.serverUnreachable)
        }
        
        guard let context = context else {
            return preLoggedInStage(localContext)
        }
        
        // Always show notification permissions if you are logged in, have a user, but haven't accepted or rejected notification permissions. This case handles both cold cases, happy flow and edge cases.
        if !localContext.hasSeenNotificationPermissions {
            return .notificationPermissions
        }
        
        // 3. ESim flow.
        if let region = context.getRegion(), region.status == .APPROVED {
            return eSIMStage(region, localContext)
        }
        
        // Possible structure for context api and kYCSteps suggestion
        // ["singpass": [.singpass, .address], "scanIC": [.nric, .jumio, .address], ["jumio": [.jumio]]]
        
        // 2. EKYC flow.
        // Specific to Singapore Singpass, normal flow, not cold start
        if localContext.selectedVerificationOption == .singpass {
            if let code = localContext.myInfoCode {
                return .verifyMyInfo(code: code)
            }
            return .singpass
        }
        
        // Specific to Singapore, normal flow, not cold start
        if localContext.selectedVerificationOption == .scanIC {
            if let region = context.getRegion(), region.kycStatusMap.NRIC_FIN == .APPROVED {
                if localContext.hasCompletedJumio {
                    if region.kycStatusMap.ADDRESS_AND_PHONE_NUMBER == .APPROVED {
                        if region.kycStatusMap.JUMIO == .REJECTED {
                            return .ohNo(.ekycRejected)
                        }
                        return .pendingVerification
                    }
                    return .address
                }
                return .jumio
            }
            return .nric
        }
        
        // All other countries ekyc flow, where you only have jumio as an option, also handles showing of selectIdentityVerificationMethod for Singapore flow
        if localContext.hasSeenVerifyIdentifyOnboarding, let selectedRegion = localContext.selectedRegion {
            let options = identityOptionsForRegion(selectedRegion)
            
            if options.count == 1 { // All other countries
                if localContext.hasCompletedJumio {
                    if context.getRegion()?.kycStatusMap.JUMIO == .REJECTED {
                        return .ohNo(.ekycRejected)
                    }
                    return .pendingVerification
                }
                return .jumio
            }
            return .selectIdentityVerificationMethod(options) // Singapore flow specific
        }
        
        // Cold start for jumio in progress to show pending verification screen since we don't have in progress state in the context.
        if localContext.hasCompletedJumio, localContext.selectedVerificationOption == nil {
            if context.getRegion()?.kycStatusMap.NRIC_FIN == .APPROVED {
                if context.getRegion()?.kycStatusMap.ADDRESS_AND_PHONE_NUMBER == .APPROVED {
                    return .verifyIdentityOnboarding
                }
            }
        }
        
        // 1. Select country.
        if localContext.selectedRegion == nil {
            if localContext.hasSeenRegionOnboarding {
                return .selectRegion
            }
            return .regionOnboarding
        }
        
        if localContext.regionVerified || context.getRegion() != nil {
            return .verifyIdentityOnboarding
        }
        if let problem = localContext.locationProblem {
            return .locationProblem(problem)
        }
        
        return .locationPermissions
    }
    
    // This is the kind of information that would be good to get from GraphQL and avoid hard-coding.
    private func identityOptionsForRegion(_ region: Region) -> [IdentityVerificationOption] {
        if region.id.lowercased() == "sg" {
            return [.scanIC, .singpass]
        }
        return [.jumio]
    }
}
