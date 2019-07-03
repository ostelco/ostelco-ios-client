//
//  StageDecider.swift
//  ostelco-core
//
//  Created by mac on 6/27/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

struct LocalContext {
    let selectedRegion: Region?
    let hasSeenLoginCarousel: Bool
    let enteredEmailAddress: String? // Needs to be persisted
    let hasFirebaseToken: Bool // Needs to be persisted
    let hasAgreedToTerms: Bool
    let hasSeenNotificationPermissions: Bool
    let regionVerified: Bool
    let hasSeenVerifyIdentifyOnboarding: Bool
    let selectedVerificationOption: StageDecider.IdentityVerificationOption?
    let myInfoCode: String? // Needs to be persisted
    let hasSeenESimOnboarding: Bool
    let hasSeenESIMInstructions: Bool
    let hasSeenAwesome: Bool
    let hasCompletedJumio: Bool // Needs to be persisted
    let hasCompletedAddress: Bool
    let serverIsUnreachable: Bool
    let hasLocationProblem: Bool
    let hasCancelledJumio: Bool
    
    init(selectedRegion: Region? = nil, hasSeenLoginCarousel: Bool = false, enteredEmailAddress: String? = nil, hasFirebaseToken: Bool = false, hasAgreedToTerms: Bool = false, hasSeenNotificationPermissions: Bool = false, regionVerified: Bool = false, hasSeenVerifyIdentifyOnboarding: Bool = false, selectedVerificationOption: StageDecider.IdentityVerificationOption? = nil, myInfoCode: String? = nil, hasSeenESimOnboarding: Bool = false, hasSeenESIMInstructions: Bool = false, hasSeenAwesome: Bool = false, hasCompletedJumio: Bool = false, hasCompletedAddress: Bool = false, serverIsUnreachable: Bool = false, hasLocationProblem: Bool = false, hasCancelledJumio: Bool = false) {
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
        self.hasLocationProblem = hasLocationProblem
        self.hasCancelledJumio = hasCancelledJumio
    }
}

struct StageDecider {
    enum Stage: Equatable {
        case home
        case loginCarousel
        case emailEntry
        case checkYourEmail(email: String)
        case legalStuff
        case notificationPermissions
        case nicknameEntry
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
        case locationProblem
    }
    
    enum IdentityVerificationOption {
        case singpass
        case scanIC
        case jumio
    }
    
    private func preLoggedInStage(_ localContext: LocalContext) -> StageDecider.Stage {
        if localContext.hasSeenLoginCarousel {
            if let emailAddress = localContext.enteredEmailAddress {
                if localContext.hasFirebaseToken {
                    if localContext.hasAgreedToTerms {
                        if localContext.hasSeenNotificationPermissions {
                            return .nicknameEntry
                        }
                        return .notificationPermissions
                    }
                    return .legalStuff
                }
                return .checkYourEmail(email: emailAddress)
            }
            return .emailEntry
        }
        
        // Cold start cases
        if let emailAddress = localContext.enteredEmailAddress {
            if localContext.hasFirebaseToken {
                return .legalStuff
            }
            return .checkYourEmail(email: emailAddress)
        }
        
        // If you don't know where to go, go to login
        return .loginCarousel
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    func compute(context: Context?, localContext: LocalContext) -> Stage {
        
        if localContext.serverIsUnreachable {
            return .ohNo(.noInternet)
        }
        
        guard let context = context else {
            return preLoggedInStage(localContext)
        }
        
        if context.getRegion()?.kycStatusMap.JUMIO == .REJECTED {
            return .ohNo(.ekycRejected)
        }
        
        if let region = context.getRegion(), region.status == .APPROVED {
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
        if let code = localContext.myInfoCode, localContext.selectedVerificationOption == .singpass {
            return .verifyMyInfo(code: code)
        }
        if localContext.selectedVerificationOption == .singpass {
            return .singpass
        }
        if localContext.selectedVerificationOption == .scanIC {
            if context.getRegion()?.kycStatusMap.NRIC_FIN == .APPROVED {
                if localContext.hasCompletedJumio {
                    if localContext.hasCompletedAddress {
                        return .pendingVerification
                    }
                    return .address
                }
                return .jumio
            }
            return .nric
        }
        if localContext.hasCompletedJumio {
            if context.getRegion()?.kycStatusMap.NRIC_FIN == .APPROVED {
                if context.getRegion()?.kycStatusMap.ADDRESS_AND_PHONE_NUMBER == .APPROVED {
                    return .pendingVerification
                }
            }
        }
        if localContext.hasSeenVerifyIdentifyOnboarding, let selectedRegion = localContext.selectedRegion {
            let options = identityOptionsForRegion(selectedRegion)
            
            if options.count == 1 {
                if localContext.hasCompletedJumio {
                    return .pendingVerification
                }
                if localContext.hasCancelledJumio {
                    return .verifyIdentityOnboarding
                }
                return .jumio
            }
            return .selectIdentityVerificationMethod(options)
        }
        if localContext.selectedRegion == nil {
            return .selectRegion
        }
        if localContext.regionVerified {
            return .verifyIdentityOnboarding
        }
        if localContext.hasLocationProblem {
            return .locationProblem
        }
        return .locationPermissions
    }
    
    // This is the kind of information that would be good to get from GraphQL and avoid hard-coding.
    private func identityOptionsForRegion(_ region: Region) -> [IdentityVerificationOption] {
        if region.id == "sg" {
            return [.scanIC, .singpass]
        }
        return [.jumio]
    }
}
