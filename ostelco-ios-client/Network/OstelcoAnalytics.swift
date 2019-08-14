//
//  OstelcoAnalytics.swift
//  ostelco-ios-client
//
//  Created by mac on 4/29/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import ostelco_core
import FirebaseAnalytics
import Crashlytics

class OstelcoAnalytics {
    
    enum AnalyticsError: Swift.Error, LocalizedError {
        case eventNameIsEmpty
        
        var localizedDescription: String {
            switch self {
            case .eventNameIsEmpty:
                return "Event name in analytics event is empty"
            }
        }
    }
    
    static func logEvent(_ event: AnalyticsEvent) {
        if event.name.isEmpty {
            var meta = event.metadata
            meta["name"] = event.name as NSObject
            meta["className"] = String(describing: event) as NSObject
            ApplicationErrors.log(AnalyticsError.eventNameIsEmpty, withAdditionalUserInfo: meta)
        } else {
            Analytics.logEvent(event.name, parameters: event.metadata)
        }
    }
}

enum AnalyticsEvent {
    case LegalStuffAgreed
    case EnteredNickname
    case ChosenCountry(country: Country)
    case ChosenIDMethod(idMethod: String)
    case ESimOnboardingIntro
    case ESimOnboardingIntroCompleted
    case ESimOnboardingPending
    case SignUpCompleted
    case UnlockMoreData
    case BecomeMemberClicked
    case BuyDataClicked
    case PushNotificationsAccepted
    case PushNotificationsDeclined

    var name: String {
        switch self {
        case .ChosenCountry:
            return "chosen_country"
        case .ChosenIDMethod:
            return "chosen_id_method"
        default:
            return String(describing: self).snakeCased() ?? ""
        }
    }
    
    var metadata: [String: NSObject] {
        switch self {
        case .ChosenCountry(let country):
            return ["country": country.countryCode as NSObject]
        case .ChosenIDMethod(let idMethod):
            return ["id_method": idMethod as NSObject]
        default:
            return [:]
        }
    }
}
