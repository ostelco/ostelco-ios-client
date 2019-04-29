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

class OstelcoAnalytics {
    static func logEvent(_ event: AnalyticsEvent) {
        Analytics.logEvent(event.name, parameters: event.metadata)
    }
}

enum AnalyticsEvent {
    case LegalStuffAgreed
    case EnteredNickname
    case ChosenCountry(country: Country)
    case ChosenIDMethod(idMethod: String)
    case DownloadingESIM
}

extension AnalyticsEvent {
    var name: String {
        switch self {
        case .ChosenCountry:
            return "chosen_country"
        case .ChosenIDMethod:
            return "chosen_id_method"
        default:
            return String(describing: self).snakeCased()! // TODO: Is this safe enough to force unwrap?
        }
    }
    
    var metadata: [String : String] {
        switch self {
        case .ChosenCountry(let country):
            return ["country": country.countryCode]
        case .ChosenIDMethod(let idMethod):
            return ["id_method": idMethod]
        default:
            return [:]
        }
    }
}
