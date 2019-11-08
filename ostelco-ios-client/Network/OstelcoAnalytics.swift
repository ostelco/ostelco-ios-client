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
import FacebookCore

public class OstelcoAnalytics {
    
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

        switch event {
        case .ecommercePurchase:
            AppEvents.logEvent(.purchased)
        default:
            break
        }
    }
    
    static func setUserId(_ id: String) {
        Analytics.setUserID(id)
    }
    
    static func setScreenName(name: String, screenClass: String? = nil) {
        Analytics.setScreenName(name, screenClass: screenClass)
    }
}

enum AnalyticsEvent {
    
    case signInFlowStarted(method: String)
    case signIn(method: String)
    case legalStuffAgreed
    case nicknameEntered
    case signup
    case permissionLocationGranted
    case permissionLocationDenied
    case permissionNotificationsGranted
    case permissionNotificationsDenied
    case getNewRegionFlowStarted(regionCode: String, countryCode: String)
    case identificationMethodChosen(regionCode: String, countryCode: String, ekycMethod: String)
    case identificationPendingValidation(regionCode: String, countryCode: String, ekycMethod: String)
    case identificationSuccessful(regionCode: String, countryCode: String, ekycMethod: String)
    case identificationFailed(regionCode: String, countryCode: String, ekycMethod: String, failureReason: String)
    case esimSetupStarted(regionCode: String, countryCode: String)
    case esimSetupCompleted(regionCode: String, countryCode: String)
    case esimSetupFailed(regionCode: String, countryCode: String)
    case logout
    case buyDataFlowStarted
    case setupApplePay
    case addToCart(name: String, sku: String, countryCode: String, amount: NSDecimalNumber, currency: String)
    case ecommercePurchase(currency: String, value: NSDecimalNumber, tax: NSDecimalNumber)
    case ecommercePurchaseFailed(failureReason: String)
    
    var name: String {
        switch self {
        case .addToCart:
            return AnalyticsEventAddToCart
        case .ecommercePurchase:
            return AnalyticsEventEcommercePurchase
        case .ecommercePurchaseFailed:
            return "purchase_failed"
        default:
            return String(describing: self).components(separatedBy: "(")[0].snakeCased() ?? ""
        }
    }
    
    var metadata: [String: Any] {
        switch self {
        case .signInFlowStarted(let method):
            return ["method": method]
        case .signIn(let method):
            return ["method": method]
        case .getNewRegionFlowStarted(let regionCode, let countryCode):
            return ["region_code": regionCode, "country_code": countryCode]
        case .identificationMethodChosen(let regionCode, let countryCode, let ekycMethod):
            return ["region_code": regionCode, "country_code": countryCode, "ekyc_method": ekycMethod]
        case .identificationPendingValidation(let regionCode, let countryCode, let ekycMethod):
            return ["region_code": regionCode, "country_code": countryCode, "ekyc_method": ekycMethod]
        case .identificationSuccessful(let regionCode, let countryCode, let ekycMethod):
            return ["region_code": regionCode, "country_code": countryCode, "ekyc_method": ekycMethod]
        case .identificationFailed(let regionCode, let countryCode, let ekycMethod, let failureReason):
            return ["region_code": regionCode, "country_code": countryCode, "ekyc_method": ekycMethod, "failure_reaon": failureReason]
        case .esimSetupStarted(let regionCode, let countryCode):
            return ["region_code": regionCode, "country_code": countryCode]
        case .esimSetupCompleted(let regionCode, let countryCode), .esimSetupFailed(let regionCode, let countryCode):
            return ["region_code": regionCode, "country_code": countryCode]
        case .addToCart(let name, let sku, let countryCode, let amount, let currency):
            return [
                "quantity": "1",
                "item_category":
                "one-time-purchase",
                "item_name": name,
                "item_sku": sku,
                "item_location": countryCode,
                "value": amount,
                "price": amount,
                "currency": currency
            ]
        case .ecommercePurchase(let currency, let value, let tax):
            return [
                "currency": currency,
                "value": value,
                "tax": tax
            ]
        case .ecommercePurchaseFailed(let failureReason):
            return ["failure_reason": failureReason]
        default:
            return [:]
        }
    }
}
