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
    let hasSeenNotificationPermissions: Bool // Needs to be persisted
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
    let hasSeenRegionOnboarding: Bool
    
    init(selectedRegion: Region? = nil, hasSeenLoginCarousel: Bool = false, enteredEmailAddress: String? = nil, hasFirebaseToken: Bool = false, hasAgreedToTerms: Bool = false, hasSeenNotificationPermissions: Bool = false, regionVerified: Bool = false, hasSeenVerifyIdentifyOnboarding: Bool = false, selectedVerificationOption: StageDecider.IdentityVerificationOption? = nil, myInfoCode: String? = nil, hasSeenESimOnboarding: Bool = false, hasSeenESIMInstructions: Bool = false, hasSeenAwesome: Bool = false, hasCompletedJumio: Bool = false, hasCompletedAddress: Bool = false, serverIsUnreachable: Bool = false, hasLocationProblem: Bool = false, hasCancelledJumio: Bool = false, hasSeenRegionOnboarding: Bool = false) {
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
        self.hasSeenRegionOnboarding = hasSeenRegionOnboarding
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
                        return .nicknameEntry
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
    func compute(context: Context?, localContext: LocalContext) -> Stage {
        
        if localContext.serverIsUnreachable {
            return .ohNo(.noInternet)
        }
        
        guard let context = context else {
            return preLoggedInStage(localContext)
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
                    if localContext.hasCompletedAddress {
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
                if localContext.hasCancelledJumio {
                    return .verifyIdentityOnboarding
                }
                return .jumio
            }
            return .selectIdentityVerificationMethod(options) // Singapore flow specific
        }
        
        // Cold start for jumio rejection to show error screen instead of ekyc on boarding screen
        if context.getRegion()?.kycStatusMap.JUMIO == .REJECTED {
            return .verifyIdentityOnboarding
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
            if localContext.hasSeenNotificationPermissions {
                if localContext.hasSeenRegionOnboarding {
                    return .selectRegion
                }
                return .regionOnboarding
            }
            
            return .notificationPermissions
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
