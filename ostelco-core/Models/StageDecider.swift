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
    let enteredEmailAddress: String?
    let hasFirebaseToken: Bool
    let hasAgreedToTerms: Bool
    let hasSeenNotificationPermissions: Bool
    let regionVerified: Bool
    let hasSeenVerifyIdentifyOnboarding: Bool
    let selectedVerificationOption: StageDecider.IdentityVerificationOption?
    let myInfoCode: String?
    let hasSeenESimOnboarding: Bool
    let hasSeenESIMInstructions: Bool
    let hasSeenAwesome: Bool
    
    init(selectedRegion: Region? = nil, hasSeenLoginCarousel: Bool = false, enteredEmailAddress: String? = nil, hasFirebaseToken: Bool = false, hasAgreedToTerms: Bool = false, hasSeenNotificationPermissions: Bool = false, regionVerified: Bool = false, hasSeenVerifyIdentifyOnboarding: Bool = false, selectedVerificationOption: StageDecider.IdentityVerificationOption? = nil, myInfoCode: String? = nil, hasSeenESimOnboarding: Bool = false, hasSeenESIMInstructions: Bool = false, hasSeenAwesome: Bool = false) {
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
        case verifyMyInfo(code: String)
        case eSimOnboarding
        case eSimInstructions
        case pendingESIMInstall
        case awesome
    }
    
    enum IdentityVerificationOption {
        case nric
        case singpass
        case jumio
    }
    
    func compute(context: Context?, localContext: LocalContext) -> Stage {
        guard let context = context else {
            
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
            
            return .loginCarousel
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
        if let code = localContext.myInfoCode {
            return .verifyMyInfo(code: code)
        }
        if localContext.selectedVerificationOption == .singpass {
            return .singpass
        }
        if localContext.hasSeenVerifyIdentifyOnboarding, let selectedRegion = localContext.selectedRegion {
            let options = identityOptionsForRegion(selectedRegion)
            return .selectIdentityVerificationMethod(options)
        }
        if localContext.selectedRegion == nil {
            return .selectRegion
        }
        if localContext.regionVerified {
            return .verifyIdentityOnboarding
        }
        return .locationPermissions
    }
    
    // This is the kind of information that would be good to get from GraphQL and avoid hard-coding.
    private func identityOptionsForRegion(_ region: Region) -> [IdentityVerificationOption] {
        if region.id == "sg" {
            return [.nric, .singpass]
        }
        return [.jumio]
    }
}
